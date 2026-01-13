//
//  ArtifactsMonitor.swift
//  Portal
//
//  Artifacts 监控服务 - 监控 Antigravity 的多 Agent 状态
//
//  Antigravity 使用 Artifacts 机制记录 AI 工作状态：
//  - brain/<session-id>/task.md: 任务清单，[/] 标记进行中
//  - conversations/<session-id>.pb: 对话内容
//  - implicit/<session-id>.pb: 隐式对话（自动分析）
//

import Foundation
import Combine

// MARK: - Agent Session Model

/// 单个 Agent 会话状态
struct AgentSession: Identifiable, Equatable {
    let id: String                    // session UUID
    var status: AgentStatus           // 当前状态
    var taskName: String?             // 任务名称（从 task.md 提取）
    var currentTask: String?          // 当前进行中的子任务
    var lastActivityTime: Date        // 最后活动时间
    var conversationType: ConversationType  // 会话类型
    
    static func == (lhs: AgentSession, rhs: AgentSession) -> Bool {
        lhs.id == rhs.id && lhs.status == rhs.status
    }
}

/// Agent 状态
enum AgentStatus: Equatable {
    case idle                    // 空闲
    case thinking                // 思考中（有活动但无明确任务）
    case planning                // 规划中（implementation_plan.md 活动）
    case executing(String?)      // 执行中（有 [/] 进行中任务）
    case completed               // 任务完成
    
    var isActive: Bool {
        switch self {
        case .idle, .completed: return false
        default: return true
        }
    }
    
    var displayText: String {
        switch self {
        case .idle: return "空闲"
        case .thinking: return "思考中..."
        case .planning: return "规划中..."
        case .executing(let task): return task ?? "执行中..."
        case .completed: return "已完成"
        }
    }
}

/// 会话类型
enum ConversationType {
    case explicit    // 用户主动发起
    case implicit    // 自动触发的分析
}

// MARK: - Artifacts Monitor

class ArtifactsMonitor: ObservableObject {
    
    // MARK: - Published Properties
    
    /// 所有活跃的 Agent 会话
    @Published var activeSessions: [AgentSession] = []
    
    /// 活跃 Agent 数量
    @Published var activeAgentCount: Int = 0
    
    /// 总 Agent 数量（包括空闲的近期会话）
    @Published var totalAgentCount: Int = 0
    
    @Published var isMonitoring: Bool = false
    
    // MARK: - Private Properties
    
    private var monitoringTimer: Timer?
    private var fileSystemSources: [DispatchSourceFileSystemObject] = []
    private var lastScanTime: Date = .distantPast
    
    // 缓存：会话ID -> 最后修改时间
    private var sessionLastModified: [String: Date] = [:]
    
    // 缓存：会话ID -> task.md 内容哈希（避免重复解析）
    private var taskContentHash: [String: Int] = [:]
    
    // 配置
    private let activeTimeout: TimeInterval = 10.0    // 10秒内有活动视为活跃
    private let recentTimeout: TimeInterval = 300.0   // 5分钟内有活动视为近期
    private let scanInterval: TimeInterval = 1.0      // 扫描间隔
    
    // 路径
    private var homeDir: String {
        if let pw = getpwuid(getuid()), let home = pw.pointee.pw_dir {
            return String(cString: home)
        }
        return "/Users/\(NSUserName())"
    }
    
    private var brainPath: String { "\(homeDir)/.gemini/antigravity/brain" }
    private var conversationsPath: String { "\(homeDir)/.gemini/antigravity/conversations" }
    private var implicitPath: String { "\(homeDir)/.gemini/antigravity/implicit" }
    
    // MARK: - Initialization
    
    init() {}
    
    // MARK: - Public Methods
    
    func startMonitoring() {
        guard !isMonitoring else { return }
        isMonitoring = true
        
        // 立即扫描一次
        scanAllSessions()
        
        // 启动定期扫描
        monitoringTimer = Timer.scheduledTimer(
            withTimeInterval: scanInterval,
            repeats: true
        ) { [weak self] _ in
            self?.scanAllSessions()
        }
        
        if let timer = monitoringTimer {
            RunLoop.main.add(timer, forMode: .common)
        }
        
        // 设置目录监控（用于即时响应）
        setupDirectoryWatchers()
        
        print("[Portal] Artifacts 多 Agent 监控已启动")
    }
    
    func stopMonitoring() {
        isMonitoring = false
        monitoringTimer?.invalidate()
        monitoringTimer = nil
        
        for source in fileSystemSources {
            source.cancel()
        }
        fileSystemSources.removeAll()
        
        print("[Portal] Artifacts 多 Agent 监控已停止")
    }
    
    /// 获取活跃的 Agent 会话列表
    func getActiveSessions() -> [AgentSession] {
        return activeSessions.filter { $0.status.isActive }
    }
    
    /// 获取主要的（最近活跃的）Agent 状态
    func getPrimaryAgentStatus() -> AgentStatus {
        // 返回最近活跃的 Agent 状态
        if let primary = activeSessions.first(where: { $0.status.isActive }) {
            return primary.status
        }
        return .idle
    }
    
    /// 获取主要的任务描述
    func getPrimaryTaskDescription() -> String? {
        if let primary = activeSessions.first(where: { $0.status.isActive }) {
            return primary.currentTask ?? primary.taskName
        }
        return nil
    }
    
    // MARK: - Private Methods
    
    private func setupDirectoryWatchers() {
        let directories = [brainPath, conversationsPath, implicitPath]
        
        for path in directories {
            guard FileManager.default.fileExists(atPath: path) else { continue }
            
            let descriptor = open(path, O_EVTONLY)
            guard descriptor >= 0 else { continue }
            
            let source = DispatchSource.makeFileSystemObjectSource(
                fileDescriptor: descriptor,
                eventMask: [.write, .extend, .rename, .attrib],
                queue: .global(qos: .userInitiated)
            )
            
            source.setEventHandler { [weak self] in
                // 目录有变化，触发扫描
                DispatchQueue.main.async {
                    self?.scanAllSessions()
                }
            }
            
            source.setCancelHandler {
                close(descriptor)
            }
            
            source.resume()
            fileSystemSources.append(source)
        }
    }
    
    private func scanAllSessions() {
        let now = Date()
        var sessions: [AgentSession] = []
        
        let fileManager = FileManager.default
        
        // 1. 扫描 brain 目录（主要任务会话）
        if let brainContents = try? fileManager.contentsOfDirectory(atPath: brainPath) {
            for sessionId in brainContents {
                let sessionPath = "\(brainPath)/\(sessionId)"
                var isDirectory: ObjCBool = false
                
                guard fileManager.fileExists(atPath: sessionPath, isDirectory: &isDirectory),
                      isDirectory.boolValue else { continue }
                
                if let session = analyzeSession(
                    sessionId: sessionId,
                    brainPath: sessionPath,
                    conversationType: .explicit,
                    now: now
                ) {
                    sessions.append(session)
                }
            }
        }
        
        // 2. 扫描 implicit 目录（隐式会话）
        if let implicitContents = try? fileManager.contentsOfDirectory(atPath: implicitPath) {
            for fileName in implicitContents where fileName.hasSuffix(".pb") {
                let sessionId = String(fileName.dropLast(3)) // 移除 .pb
                let filePath = "\(implicitPath)/\(fileName)"
                
                // 检查是否已经在 brain 目录中处理过
                if sessions.contains(where: { $0.id == sessionId }) { continue }
                
                if let session = analyzeImplicitSession(
                    sessionId: sessionId,
                    filePath: filePath,
                    now: now
                ) {
                    sessions.append(session)
                }
            }
        }
        
        // 3. 检查 conversations 目录的活动（补充检测）
        if let convContents = try? fileManager.contentsOfDirectory(atPath: conversationsPath) {
            for fileName in convContents where fileName.hasSuffix(".pb") {
                let sessionId = String(fileName.dropLast(3))
                let filePath = "\(conversationsPath)/\(fileName)"
                
                // 如果已存在，更新活动时间
                if let index = sessions.firstIndex(where: { $0.id == sessionId }) {
                    if let attrs = try? fileManager.attributesOfItem(atPath: filePath),
                       let modDate = attrs[.modificationDate] as? Date {
                        if modDate > sessions[index].lastActivityTime {
                            sessions[index].lastActivityTime = modDate
                            // 如果有最近活动，更新状态
                            if now.timeIntervalSince(modDate) < activeTimeout {
                                if sessions[index].status == .idle {
                                    sessions[index].status = .thinking
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // 4. 过滤：只保留近期有活动的会话
        let recentSessions = sessions.filter {
            now.timeIntervalSince($0.lastActivityTime) < recentTimeout
        }
        
        // 5. 按活动时间排序（最近的在前）
        let sortedSessions = recentSessions.sorted {
            $0.lastActivityTime > $1.lastActivityTime
        }
        
        // 6. 更新状态
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.activeSessions = sortedSessions
            self.activeAgentCount = sortedSessions.filter { $0.status.isActive }.count
            self.totalAgentCount = sortedSessions.count
            
            // 发送通知
            self.notifyStatusChange()
        }
    }
    
    private func analyzeSession(
        sessionId: String,
        brainPath: String,
        conversationType: ConversationType,
        now: Date
    ) -> AgentSession? {
        let fileManager = FileManager.default
        
        // 检查关键文件
        let taskMdPath = "\(brainPath)/task.md"
        let planPath = "\(brainPath)/implementation_plan.md"
        let walkthroughPath = "\(brainPath)/walkthrough.md"
        
        var lastModified: Date = .distantPast
        var status: AgentStatus = .idle
        var taskName: String?
        var currentTask: String?
        
        // 1. 检查 task.md
        if fileManager.fileExists(atPath: taskMdPath),
           let attrs = try? fileManager.attributesOfItem(atPath: taskMdPath),
           let modDate = attrs[.modificationDate] as? Date {
            
            lastModified = max(lastModified, modDate)
            
            // 解析 task.md 内容
            if let content = try? String(contentsOfFile: taskMdPath, encoding: .utf8) {
                let parsed = parseTaskMd(content)
                taskName = parsed.taskName
                currentTask = parsed.currentTask
                
                // 如果有进行中的任务
                if let task = currentTask {
                    if now.timeIntervalSince(modDate) < activeTimeout {
                        status = .executing(task)
                    }
                }
            }
        }
        
        // 2. 检查 implementation_plan.md
        if fileManager.fileExists(atPath: planPath),
           let attrs = try? fileManager.attributesOfItem(atPath: planPath),
           let modDate = attrs[.modificationDate] as? Date {
            
            if modDate > lastModified {
                lastModified = modDate
                if now.timeIntervalSince(modDate) < activeTimeout {
                    status = .planning
                }
            }
        }
        
        // 3. 检查 walkthrough.md（表示任务完成）
        if fileManager.fileExists(atPath: walkthroughPath),
           let attrs = try? fileManager.attributesOfItem(atPath: walkthroughPath),
           let modDate = attrs[.modificationDate] as? Date {
            
            if modDate > lastModified {
                lastModified = modDate
                // walkthrough 创建表示任务完成
                if now.timeIntervalSince(modDate) < activeTimeout {
                    status = .completed
                }
            }
        }
        
        // 4. 检查对应的 conversation pb 文件
        let convPath = "\(conversationsPath)/\(sessionId).pb"
        if fileManager.fileExists(atPath: convPath),
           let attrs = try? fileManager.attributesOfItem(atPath: convPath),
           let modDate = attrs[.modificationDate] as? Date {
            
            if modDate > lastModified {
                lastModified = modDate
            }
            
            // 如果 pb 文件最近有活动，但状态是空闲，说明在对话中
            if now.timeIntervalSince(modDate) < activeTimeout && status == .idle {
                status = .thinking
            }
        }
        
        // 如果太久没有活动，标记为空闲
        if now.timeIntervalSince(lastModified) > activeTimeout {
            if status != .completed {
                status = .idle
            }
        }
        
        // 只返回有效的会话（有活动记录的）
        guard lastModified > .distantPast else { return nil }
        
        return AgentSession(
            id: sessionId,
            status: status,
            taskName: taskName,
            currentTask: currentTask,
            lastActivityTime: lastModified,
            conversationType: conversationType
        )
    }
    
    private func analyzeImplicitSession(
        sessionId: String,
        filePath: String,
        now: Date
    ) -> AgentSession? {
        let fileManager = FileManager.default
        
        guard let attrs = try? fileManager.attributesOfItem(atPath: filePath),
              let modDate = attrs[.modificationDate] as? Date else {
            return nil
        }
        
        // 隐式会话只有 pb 文件，根据修改时间判断状态
        let status: AgentStatus
        if now.timeIntervalSince(modDate) < activeTimeout {
            status = .thinking
        } else {
            status = .idle
        }
        
        return AgentSession(
            id: sessionId,
            status: status,
            taskName: "自动分析",
            currentTask: nil,
            lastActivityTime: modDate,
            conversationType: .implicit
        )
    }
    
    /// 解析 task.md 文件内容
    private func parseTaskMd(_ content: String) -> (taskName: String?, currentTask: String?) {
        let lines = content.components(separatedBy: .newlines)
        var taskName: String?
        var currentTask: String?
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            // 提取任务名称（# Task: ...）
            if trimmed.hasPrefix("# Task:") || trimmed.hasPrefix("#Task:") {
                taskName = trimmed
                    .replacingOccurrences(of: "# Task:", with: "")
                    .replacingOccurrences(of: "#Task:", with: "")
                    .trimmingCharacters(in: .whitespaces)
            }
            
            // 查找进行中的任务 `- [/]`
            if trimmed.hasPrefix("- [/]") {
                // 提取任务描述，移除 HTML 注释
                var task = trimmed
                    .replacingOccurrences(of: "- [/]", with: "")
                    .trimmingCharacters(in: .whitespaces)
                
                // 移除 <!-- id: X --> 注释
                if let commentRange = task.range(of: "<!--.*-->", options: .regularExpression) {
                    task = task.replacingCharacters(in: commentRange, with: "")
                        .trimmingCharacters(in: .whitespaces)
                }
                
                currentTask = task.isEmpty ? nil : task
                break // 只取第一个进行中的任务
            }
        }
        
        return (taskName, currentTask)
    }
    
    private func notifyStatusChange() {
        let activeCount = activeSessions.filter { $0.status.isActive }.count
        
        if activeCount > 0 {
            NotificationCenter.default.post(
                name: .aiCallStarted,
                object: nil,
                userInfo: [
                    "ideType": IDEType.antigravity,
                    "agentCount": activeCount
                ]
            )
        }
    }
    
    deinit {
        stopMonitoring()
    }
}

// MARK: - Compatibility Extensions

extension ArtifactsMonitor {
    /// 兼容旧 API：获取 AI 状态
    func getLatestStatus(for ideType: IDEType) -> AIStatus {
        guard ideType == .antigravity else { return .idle }
        
        let status = getPrimaryAgentStatus()
        switch status {
        case .idle: return .idle
        case .thinking: return .processing("思考中...")
        case .planning: return .processing("规划中...")
        case .executing(let task): return .processing(task ?? "执行中...")
        case .completed: return .idle
        }
    }
    
    /// 兼容旧 API：检查是否有 AI 活动
    func isAIActive(for ideType: IDEType) -> Bool {
        guard ideType == .antigravity else { return false }
        return activeAgentCount > 0
    }
}
