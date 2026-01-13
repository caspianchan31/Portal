//
//  LogParser.swift
//  Portal
//
//  日志解析服务 - 解析 IDE 日志获取 AI 状态
//

import Foundation
import Combine
import SQLite3

/// 日志事件
struct LogEvent {
    let timestamp: Date
    let ideType: IDEType
    let eventType: LogEventType
    let message: String
    let metadata: [String: Any]?
}

enum LogEventType {
    case aiRequestStart
    case aiRequestEnd
    case aiError
    case unknown
}

class LogParser: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var latestEvents: [IDEType: LogEvent] = [:]
    @Published var isMonitoring: Bool = false
    
    // MARK: - Private Properties
    
    /// 文件句柄 key: "IDEType-filePath"
    private var fileHandles: [String: FileHandle] = [:]
    private var monitoringTimer: Timer?
    private var lastReadPositions: [String: UInt64] = [:]
    /// 记录每个文件句柄对应的 IDE 类型
    private var handleToIDEType: [String: IDEType] = [:]
    
    /// Cursor AI 数据库监控
    private var lastCursorDbTimestamp: Int64 = 0
    private var cursorDbPath: String {
        return "\(homeDirectory)/.cursor/ai-tracking/ai-code-tracking.db"
    }
    
    // 真实用户主目录（绕过沙盒）
    private var homeDirectory: String {
        if let pw = getpwuid(getuid()), let home = pw.pointee.pw_dir {
            return String(cString: home)
        } else {
            let userName = NSUserName()
            return "/Users/\(userName)"
        }
    }
    
    // Cursor 日志基础目录
    private var cursorLogsBasePath: String {
        return "\(homeDirectory)/Library/Application Support/Cursor/logs/"
    }
    
    // VS Code 日志基础目录
    private var vscodeLogsBasePath: String {
        return "\(homeDirectory)/Library/Application Support/Code/logs/"
    }
    
    // AI 请求关键词
    private let aiRequestPatterns: [IDEType: [String]] = [
        .cursor: [
            // Cursor Agent 核心日志关键词
            "toolcalleventservice",
            // Anthropic/Claude 相关
            "anthropic", "claude", "claude-3", "claude-sonnet", "claude-opus",
            // OpenAI 相关
            "openai", "gpt", "gpt-4", "gpt-4o",
            // Cursor 特定关键词
            "cursor", "copilot++", "composer", "aichat",
            // 通用 AI 请求关键词
            "completion", "chat/completions", "messages", "streaming",
            // Agent 模式关键词
            "agent", "tool_use", "tool_call", "function_call"
        ],
        .antigravity: ["gemini", "palm", "google.ai", "generateContent"],
        .vscode: ["copilot", "github.ai", "completion"]
    ]
    
    // MARK: - Initialization
    
    init() {}
    
    // MARK: - Public Methods
    
    func startMonitoring() {
        isMonitoring = true
        
        // 初始化 Cursor 日志文件监控
        setupCursorLogMonitoring()
        
        // 初始化 Cursor 数据库监控
        setupCursorDatabaseMonitoring()
        
        // 初始化 VS Code 日志文件监控
        setupLogMonitoring(for: .vscode, at: vscodeLogsBasePath)
        
        // 定期检查日志更新
        monitoringTimer = Timer.scheduledTimer(
            withTimeInterval: 1.0,
            repeats: true
        ) { [weak self] _ in
            self?.checkLogUpdates()
            self?.checkCursorDatabaseUpdates()
        }
        
        print("[Portal] 日志监控已启动")
    }
    
    /// 设置 Cursor 数据库监控
    private func setupCursorDatabaseMonitoring() {
        let fileManager = FileManager.default
        
        guard fileManager.fileExists(atPath: cursorDbPath) else {
            print("[Portal] Cursor AI 数据库不存在: \(cursorDbPath)")
            return
        }
        
        // 获取当前最新的时间戳
        if let timestamp = getLatestCursorTimestamp() {
            lastCursorDbTimestamp = timestamp
            print("[Portal] 已开始监控 Cursor AI 数据库，初始时间戳: \(timestamp)")
        }
    }
    
    /// 检查 Cursor 数据库更新
    private func checkCursorDatabaseUpdates() {
        guard let latestTimestamp = getLatestCursorTimestamp() else { return }
        
        // 检查是否有新的 AI 活动
        if latestTimestamp > lastCursorDbTimestamp {
            // 查询新记录
            if let newRecords = getNewCursorRecords(since: lastCursorDbTimestamp) {
                for record in newRecords {
                    let event = LogEvent(
                        timestamp: Date(timeIntervalSince1970: Double(record.timestamp) / 1000.0),
                        ideType: .cursor,
                        eventType: .aiRequestStart,
                        message: "AI 生成代码: \(record.fileName)",
                        metadata: [
                            "source": record.source,
                            "model": record.model,
                            "file": record.fileName
                        ]
                    )
                    
                    DispatchQueue.main.async {
                        self.latestEvents[.cursor] = event
                        self.notifyEventDetected(event)
                    }
                }
            }
            
            lastCursorDbTimestamp = latestTimestamp
        }
    }
    
    /// 从 Cursor 数据库获取最新时间戳（使用原生 SQLite API）
    private func getLatestCursorTimestamp() -> Int64? {
        guard FileManager.default.fileExists(atPath: cursorDbPath) else { return nil }
        
        var db: OpaquePointer?
        guard sqlite3_open_v2(cursorDbPath, &db, SQLITE_OPEN_READONLY, nil) == SQLITE_OK else {
            return nil
        }
        defer { sqlite3_close(db) }
        
        var stmt: OpaquePointer?
        let query = "SELECT MAX(createdAt) FROM ai_code_hashes;"
        
        guard sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK else {
            return nil
        }
        defer { sqlite3_finalize(stmt) }
        
        if sqlite3_step(stmt) == SQLITE_ROW {
            return sqlite3_column_int64(stmt, 0)
        }
        
        return nil
    }
    
    /// 获取新的 Cursor AI 记录（使用原生 SQLite API）
    private func getNewCursorRecords(since timestamp: Int64) -> [(source: String, fileName: String, model: String, timestamp: Int64)]? {
        guard FileManager.default.fileExists(atPath: cursorDbPath) else { return nil }
        
        var db: OpaquePointer?
        guard sqlite3_open_v2(cursorDbPath, &db, SQLITE_OPEN_READONLY, nil) == SQLITE_OK else {
            return nil
        }
        defer { sqlite3_close(db) }
        
        var stmt: OpaquePointer?
        let query = "SELECT source, fileName, model, createdAt FROM ai_code_hashes WHERE createdAt > ? ORDER BY createdAt DESC LIMIT 10;"
        
        guard sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK else {
            return nil
        }
        defer { sqlite3_finalize(stmt) }
        
        sqlite3_bind_int64(stmt, 1, timestamp)
        
        var records: [(source: String, fileName: String, model: String, timestamp: Int64)] = []
        
        while sqlite3_step(stmt) == SQLITE_ROW {
            var source = "unknown"
            var filePath = ""
            var model = "unknown"
            
            if let sourcePtr = sqlite3_column_text(stmt, 0) {
                source = String(cString: sourcePtr)
            }
            if let filePtr = sqlite3_column_text(stmt, 1) {
                filePath = String(cString: filePtr)
            }
            if let modelPtr = sqlite3_column_text(stmt, 2) {
                model = String(cString: modelPtr)
            }
            let ts = sqlite3_column_int64(stmt, 3)
            
            let fileName = (filePath as NSString).lastPathComponent
            if !fileName.isEmpty {
                records.append((source: source, fileName: fileName, model: model, timestamp: ts))
            }
        }
        
        return records.isEmpty ? nil : records
    }
    
    /// 设置 Cursor 特定的日志监控
    private func setupCursorLogMonitoring() {
        let fileManager = FileManager.default
        let basePath = cursorLogsBasePath
        
        guard fileManager.fileExists(atPath: basePath) else {
            print("[Portal] Cursor 日志目录不存在: \(basePath)")
            return
        }
        
        // 找到最新的时间戳目录
        do {
            let contents = try fileManager.contentsOfDirectory(atPath: basePath)
            // 时间戳目录格式: 20260114T014142
            let timestampDirs = contents.filter { $0.contains("T") && $0.count == 15 }
                .sorted { $0 > $1 }  // 降序排列，最新的在前
            
            guard let latestDir = timestampDirs.first else {
                print("[Portal] Cursor 日志目录中没有找到时间戳子目录")
                return
            }
            
            let latestPath = (basePath as NSString).appendingPathComponent(latestDir)
            
            // 查找 renderer.log（包含 AI 工具调用日志）
            let rendererLogPaths = [
                (latestPath as NSString).appendingPathComponent("window1/renderer.log"),
                (latestPath as NSString).appendingPathComponent("window2/renderer.log"),
                (latestPath as NSString).appendingPathComponent("window3/renderer.log")
            ]
            
            for rendererLogPath in rendererLogPaths {
                if fileManager.fileExists(atPath: rendererLogPath) {
                    openLogFile(for: .cursor, at: rendererLogPath)
                }
            }
            
            // 也监控 exthost.log
            let exthostLogPath = (latestPath as NSString).appendingPathComponent("window1/exthost/exthost.log")
            if fileManager.fileExists(atPath: exthostLogPath) {
                openLogFile(for: .cursor, at: exthostLogPath)
            }
            
        } catch {
            print("[Portal] 读取 Cursor 日志目录失败: \(error)")
        }
    }
    
    func stopMonitoring() {
        isMonitoring = false
        monitoringTimer?.invalidate()
        monitoringTimer = nil
        
        // 关闭所有文件句柄
        for (_, handle) in fileHandles {
            try? handle.close()
        }
        fileHandles.removeAll()
        handleToIDEType.removeAll()
        lastReadPositions.removeAll()
        
        print("[Portal] 日志监控已停止")
    }
    
    /// 获取特定 IDE 的最新 AI 状态
    func getLatestStatus(for ideType: IDEType) -> AIStatus {
        guard let event = latestEvents[ideType] else {
            return .idle
        }
        
        switch event.eventType {
        case .aiRequestStart:
            return .processing(event.message)
        case .aiRequestEnd:
            if let duration = event.metadata?["duration"] as? TimeInterval {
                return .completed(duration)
            }
            return .idle
        case .aiError:
            return .error(event.message)
        case .unknown:
            return .idle
        }
    }
    
    // MARK: - Private Methods
    
    private func setupLogMonitoring(for ideType: IDEType, at basePath: String) {
        let fileManager = FileManager.default
        
        // 检查目录是否存在
        guard fileManager.fileExists(atPath: basePath) else {
            print("[Portal] 日志目录不存在: \(basePath)")
            return
        }
        
        // 查找最新的日志文件
        do {
            let contents = try fileManager.contentsOfDirectory(atPath: basePath)
            let logFiles = contents.filter { $0.hasSuffix(".log") || $0.hasSuffix(".txt") }
            
            // 按修改时间排序，取最新的
            let sortedFiles = logFiles.compactMap { fileName -> (String, Date)? in
                let filePath = (basePath as NSString).appendingPathComponent(fileName)
                guard let attrs = try? fileManager.attributesOfItem(atPath: filePath),
                      let modDate = attrs[.modificationDate] as? Date else {
                    return nil
                }
                return (filePath, modDate)
            }.sorted { $0.1 > $1.1 }
            
            if let latestLog = sortedFiles.first {
                openLogFile(for: ideType, at: latestLog.0)
            }
        } catch {
            print("[Portal] 读取日志目录失败: \(error)")
        }
    }
    
    private func openLogFile(for ideType: IDEType, at path: String) {
        guard let handle = FileHandle(forReadingAtPath: path) else {
            print("[Portal] 无法打开日志文件: \(path)")
            return
        }
        
        let key = "\(ideType.rawValue)-\(path)"
        
        // 移动到文件末尾，只监控新内容
        handle.seekToEndOfFile()
        lastReadPositions[key] = handle.offsetInFile
        fileHandles[key] = handle
        handleToIDEType[key] = ideType
        
        print("[Portal] 已开始监控日志: \(path)")
    }
    
    private func checkLogUpdates() {
        for (key, handle) in fileHandles {
            guard let ideType = handleToIDEType[key] else { continue }
            
            let currentPosition = handle.offsetInFile
            let lastPosition = lastReadPositions[key] ?? 0
            
            // 检查是否有新内容
            if currentPosition > lastPosition {
                handle.seek(toFileOffset: lastPosition)
                let newData = handle.readDataToEndOfFile()
                lastReadPositions[key] = handle.offsetInFile
                
                if let newContent = String(data: newData, encoding: .utf8) {
                    parseLogContent(newContent, for: ideType)
                }
            }
        }
    }
    
    private func parseLogContent(_ content: String, for ideType: IDEType) {
        let lines = content.components(separatedBy: .newlines)
        
        guard let patterns = aiRequestPatterns[ideType] else { return }
        
        for line in lines {
            let lowerLine = line.lowercased()
            
            // 检查是否包含 AI 相关关键词
            for pattern in patterns {
                if lowerLine.contains(pattern) {
                    let event = parseLogLine(line, for: ideType)
                    if event.eventType != .unknown {
                        DispatchQueue.main.async {
                            self.latestEvents[ideType] = event
                            self.notifyEventDetected(event)
                        }
                    }
                    break
                }
            }
        }
    }
    
    private func parseLogLine(_ line: String, for ideType: IDEType) -> LogEvent {
        let timestamp = extractTimestamp(from: line) ?? Date()
        let lowerLine = line.lowercased()
        
        // Cursor 特定的请求模式检测
        if ideType == .cursor {
            // ToolCallEventService 日志解析（Cursor Agent 模式核心日志）
            if line.contains("ToolCallEventService") {
                // 提取工具名称
                let toolName = extractToolName(from: line)
                
                if line.contains("tool call start") {
                    let displayName = toolDisplayName(toolName)
                    return LogEvent(
                        timestamp: timestamp,
                        ideType: ideType,
                        eventType: .aiRequestStart,
                        message: displayName,
                        metadata: ["tool": toolName]
                    )
                }
                
                if line.contains("tool call end") {
                    return LogEvent(
                        timestamp: timestamp,
                        ideType: ideType,
                        eventType: .aiRequestEnd,
                        message: "工具调用完成",
                        metadata: ["tool": toolName]
                    )
                }
            }
            
            // Agent 模式检测
            if lowerLine.contains("agent") && (lowerLine.contains("start") || lowerLine.contains("begin") || lowerLine.contains("running")) {
                return LogEvent(
                    timestamp: timestamp,
                    ideType: ideType,
                    eventType: .aiRequestStart,
                    message: "Agent 模式运行中...",
                    metadata: nil
                )
            }
            
            // Composer 模式检测
            if lowerLine.contains("composer") && (lowerLine.contains("start") || lowerLine.contains("generate")) {
                return LogEvent(
                    timestamp: timestamp,
                    ideType: ideType,
                    eventType: .aiRequestStart,
                    message: "Composer 生成中...",
                    metadata: nil
                )
            }
        }
        
        // 通用请求开始检测
        if lowerLine.contains("request") && 
           (lowerLine.contains("start") || lowerLine.contains("sending") || lowerLine.contains("begin")) {
            return LogEvent(
                timestamp: timestamp,
                ideType: ideType,
                eventType: .aiRequestStart,
                message: "AI 请求中...",
                metadata: nil
            )
        }
        
        // 流式响应检测
        if lowerLine.contains("streaming") && !lowerLine.contains("end") && !lowerLine.contains("stop") {
            return LogEvent(
                timestamp: timestamp,
                ideType: ideType,
                eventType: .aiRequestStart,
                message: "流式响应中...",
                metadata: nil
            )
        }
        
        // 检测请求完成
        if lowerLine.contains("response") || 
           lowerLine.contains("completed") ||
           lowerLine.contains("received") ||
           lowerLine.contains("finished") ||
           (lowerLine.contains("streaming") && (lowerLine.contains("end") || lowerLine.contains("stop"))) {
            let duration = extractDuration(from: line)
            return LogEvent(
                timestamp: timestamp,
                ideType: ideType,
                eventType: .aiRequestEnd,
                message: "请求完成",
                metadata: duration != nil ? ["duration": duration!] : nil
            )
        }
        
        // 检测错误
        if lowerLine.contains("error") || 
           lowerLine.contains("failed") ||
           lowerLine.contains("timeout") ||
           lowerLine.contains("rate_limit") ||
           lowerLine.contains("quota") {
            let errorMessage = extractErrorMessage(from: line)
            return LogEvent(
                timestamp: timestamp,
                ideType: ideType,
                eventType: .aiError,
                message: errorMessage,
                metadata: nil
            )
        }
        
        return LogEvent(
            timestamp: timestamp,
            ideType: ideType,
            eventType: .unknown,
            message: line,
            metadata: nil
        )
    }
    
    /// 从日志行中提取工具名称
    private func extractToolName(from line: String) -> String {
        // 格式: ToolCallEventService: Tracked tool call start - toolu_xxx (tool_name)
        if let openParen = line.lastIndex(of: "("),
           let closeParen = line.lastIndex(of: ")"),
           openParen < closeParen {
            let startIndex = line.index(after: openParen)
            return String(line[startIndex..<closeParen])
        }
        return "unknown"
    }
    
    /// 工具名称的友好显示
    private func toolDisplayName(_ toolName: String) -> String {
        switch toolName {
        case "read_file":
            return "读取文件..."
        case "write", "write_file":
            return "写入文件..."
        case "run_terminal_cmd":
            return "执行终端命令..."
        case "todo_write":
            return "更新任务列表..."
        case "read_lints":
            return "检查代码问题..."
        case "ripgrep_raw_search", "grep", "search":
            return "搜索代码..."
        case "glob", "list_files":
            return "查找文件..."
        case "semantic_search":
            return "语义搜索..."
        case "edit", "str_replace":
            return "编辑代码..."
        default:
            return "执行 \(toolName)..."
        }
    }
    
    private func extractTimestamp(from line: String) -> Date? {
        // 常见的日志时间格式
        let patterns = [
            "\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}",
            "\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}",
            "\\[\\d{2}:\\d{2}:\\d{2}\\]"
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern),
               let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)),
               let range = Range(match.range, in: line) {
                let dateString = String(line[range])
                
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                if let date = formatter.date(from: dateString) {
                    return date
                }
            }
        }
        
        return nil
    }
    
    private func extractDuration(from line: String) -> TimeInterval? {
        // 匹配类似 "2.5s" 或 "2500ms" 或 "2.5 seconds" 的模式
        let patterns = [
            "(\\d+\\.?\\d*)\\s*s(?:ec)?(?:onds)?",
            "(\\d+)\\s*ms"
        ]
        
        for (index, pattern) in patterns.enumerated() {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
               let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)),
               match.numberOfRanges > 1,
               let range = Range(match.range(at: 1), in: line) {
                let numberString = String(line[range])
                if let number = Double(numberString) {
                    // 如果是毫秒，转换为秒
                    return index == 1 ? number / 1000.0 : number
                }
            }
        }
        
        return nil
    }
    
    private func extractErrorMessage(from line: String) -> String {
        // 尝试提取错误信息
        if let colonIndex = line.lastIndex(of: ":") {
            let message = String(line[line.index(after: colonIndex)...]).trimmingCharacters(in: .whitespaces)
            return message.isEmpty ? "未知错误" : message
        }
        return "未知错误"
    }
    
    private func notifyEventDetected(_ event: LogEvent) {
        switch event.eventType {
        case .aiRequestStart:
            NotificationCenter.default.post(
                name: .aiCallStarted,
                object: nil,
                userInfo: ["ideType": event.ideType]
            )
        case .aiRequestEnd:
            NotificationCenter.default.post(
                name: .aiCallCompleted,
                object: nil,
                userInfo: [
                    "ideType": event.ideType,
                    "duration": event.metadata?["duration"] ?? 0
                ]
            )
        case .aiError:
            print("[Portal] AI 错误: \(event.message)")
        case .unknown:
            break
        }
    }
    
    deinit {
        stopMonitoring()
    }
}
