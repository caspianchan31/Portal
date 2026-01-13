//
//  IDEDetector.swift
//  Portal
//
//  IDE 检测服务 - 监控已安装 IDE 的运行状态和 AI 活动
//

import Foundation
import AppKit
import Combine

class IDEDetector: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var detectedIDEs: [IDE] = []
    @Published var overallStatus: AIOverallStatus = .idle
    
    /// Antigravity 的多 Agent 会话（新增）
    @Published var antigravityAgentSessions: [AgentSession] = []
    
    // MARK: - Private Properties
    
    private var monitoringTimer: Timer?
    private let workspaceNotificationCenter = NSWorkspace.shared.notificationCenter
    private var cancellables = Set<AnyCancellable>()
    
    // 监控间隔（秒）
    private let monitoringInterval: TimeInterval = 1.0
    
    // 支持的 IDE 类型
    private let supportedIDETypes: [IDEType] = [.cursor, .antigravity]
    
    // 子服务
    private let artifactsMonitor = ArtifactsMonitor()  // 新的 Artifacts 监控
    private let logParser = LogParser()                 // 保留日志解析（用于 Cursor）
    
    // 追踪 AI 调用时间
    private var aiCallStartTimes: [IDEType: Date] = [:]
    
    // MARK: - Initialization
    
    init() {
        setupNotifications()
        setupServiceBindings()
    }
    
    // MARK: - Public Methods
    
    func startMonitoring() {
        // 立即执行一次检测
        detectRunningIDEs()
        
        // 启动定期监控
        monitoringTimer = Timer.scheduledTimer(
            withTimeInterval: monitoringInterval,
            repeats: true
        ) { [weak self] _ in
            self?.detectRunningIDEs()
        }
        
        // 确保计时器在滚动等操作时也能触发
        if let timer = monitoringTimer {
            RunLoop.main.add(timer, forMode: .common)
        }
        
        // 启动子服务
        artifactsMonitor.startMonitoring()
        logParser.startMonitoring()
        
        print("[Portal] 开始监控 IDE")
    }
    
    func stopMonitoring() {
        monitoringTimer?.invalidate()
        monitoringTimer = nil
        
        // 停止子服务
        artifactsMonitor.stopMonitoring()
        logParser.stopMonitoring()
        
        print("[Portal] 停止监控 IDE")
    }
    
    /// 获取 Antigravity 活跃的 Agent 数量
    func getActiveAgentCount() -> Int {
        return artifactsMonitor.activeAgentCount
    }
    
    /// 获取 Antigravity 总 Agent 数量
    func getTotalAgentCount() -> Int {
        return artifactsMonitor.totalAgentCount
    }
    
    /// 获取 Antigravity 活跃的 Agent 会话列表
    func getActiveAgentSessions() -> [AgentSession] {
        return artifactsMonitor.getActiveSessions()
    }
    
    // MARK: - Private Methods
    
    private func setupNotifications() {
        // 监听应用启动
        workspaceNotificationCenter.addObserver(
            forName: NSWorkspace.didLaunchApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.handleAppLaunch(notification)
        }
        
        // 监听应用退出
        workspaceNotificationCenter.addObserver(
            forName: NSWorkspace.didTerminateApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.handleAppTerminate(notification)
        }
        
        // 监听 AI 调用事件
        NotificationCenter.default.addObserver(
            forName: .aiCallStarted,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.handleAICallStarted(notification)
        }
        
        NotificationCenter.default.addObserver(
            forName: .aiCallCompleted,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.handleAICallCompleted(notification)
        }
    }
    
    private func setupServiceBindings() {
        // 监听 Artifacts 监控的多 Agent 状态变化
        artifactsMonitor.$activeSessions
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sessions in
                self?.antigravityAgentSessions = sessions
                self?.detectRunningIDEs()
            }
            .store(in: &cancellables)
        
        // 监听 Artifacts 监控的活跃计数变化
        artifactsMonitor.$activeAgentCount
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.detectRunningIDEs()
            }
            .store(in: &cancellables)
        
        // 监听日志解析的事件（用于 Cursor）
        logParser.$latestEvents
            .receive(on: DispatchQueue.main)
            .sink { [weak self] events in
                self?.detectRunningIDEs()
            }
            .store(in: &cancellables)
    }
    
    private func handleAppLaunch(_ notification: Notification) {
        guard let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
              let bundleId = app.bundleIdentifier else { return }
        
        // 检查是否是支持的 IDE
        if let ideType = supportedIDETypes.first(where: { $0.bundleIdentifier == bundleId }) {
            print("[Portal] 检测到 IDE 启动: \(ideType.rawValue)")
            detectRunningIDEs()
        }
    }
    
    private func handleAppTerminate(_ notification: Notification) {
        guard let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
              let bundleId = app.bundleIdentifier else { return }
        
        // 检查是否是支持的 IDE
        if let ideType = supportedIDETypes.first(where: { $0.bundleIdentifier == bundleId }) {
            print("[Portal] 检测到 IDE 退出: \(ideType.rawValue)")
            aiCallStartTimes.removeValue(forKey: ideType)
            detectRunningIDEs()
        }
    }
    
    private func handleAICallStarted(_ notification: Notification) {
        guard let ideType = notification.userInfo?["ideType"] as? IDEType else { return }
        aiCallStartTimes[ideType] = Date()
        detectRunningIDEs()
    }
    
    private func handleAICallCompleted(_ notification: Notification) {
        guard let ideType = notification.userInfo?["ideType"] as? IDEType else { return }
        aiCallStartTimes.removeValue(forKey: ideType)
        detectRunningIDEs()
    }
    
    private func detectRunningIDEs() {
        let runningApps = NSWorkspace.shared.runningApplications
        var updatedIDEs: [IDE] = []
        
        for ideType in supportedIDETypes {
            var ide = IDE(type: ideType)
            
            if let app = runningApps.first(where: { $0.bundleIdentifier == ideType.bundleIdentifier }) {
                ide.isRunning = true
                ide.processId = app.processIdentifier
                
                // 根据 IDE 类型使用不同的检测方法
                switch ideType {
                case .antigravity:
                    // 使用 ArtifactsMonitor 获取精确的多 Agent 状态
                    let status = artifactsMonitor.getPrimaryAgentStatus()
                    let taskDescription = artifactsMonitor.getPrimaryTaskDescription()
                    
                    switch status {
                    case .idle:
                        ide.aiStatus = .idle
                    case .thinking:
                        ide.aiStatus = .processing("思考中...")
                    case .planning:
                        ide.aiStatus = .processing("规划中...")
                    case .executing(let task):
                        ide.aiStatus = .processing(task ?? taskDescription ?? "执行中...")
                    case .completed:
                        ide.aiStatus = .idle
                    }
                    
                    // 设置多 Agent 计数
                    ide.activeAgentCount = artifactsMonitor.activeAgentCount
                    ide.totalAgentCount = artifactsMonitor.totalAgentCount
                    
                case .cursor:
                    // Cursor 使用日志解析
                    ide.aiStatus = detectCursorAIStatus(processId: app.processIdentifier)
                    
                default:
                    ide.aiStatus = .idle
                }
                
                ide.lastAICallTime = aiCallStartTimes[ideType]
                
            } else {
                ide.isRunning = false
                ide.aiStatus = .idle
            }
            
            updatedIDEs.append(ide)
        }
        
        self.detectedIDEs = updatedIDEs
        self.updateOverallStatus()
    }
    
    private func detectCursorAIStatus(processId: pid_t) -> AIStatus {
        // 检查日志解析
        let logStatus = logParser.getLatestStatus(for: .cursor)
        if case .processing(let message) = logStatus {
            // 如果有具体的任务描述，使用它
            if let msg = message, !msg.isEmpty {
                return .processing(msg)
            }
            return .processing("AI 处理中...")
        }
        
        // 检查是否有追踪中的调用
        if let startTime = aiCallStartTimes[.cursor] {
            let duration = Date().timeIntervalSince(startTime)
            return .processing(String(format: "请求中 (%.1fs)", duration))
        }
        
        // 检查是否有错误状态
        if case .error(let errorMsg) = logStatus {
            return .error(errorMsg)
        }
        
        return .idle
    }
    
    private func updateOverallStatus() {
        let activeAIs = detectedIDEs.filter { $0.aiStatus.isActive }
        let hasError = detectedIDEs.contains { 
            if case .error = $0.aiStatus { return true }
            return false
        }
        
        if hasError {
            overallStatus = .error
        } else if activeAIs.isEmpty {
            overallStatus = .idle
        } else {
            overallStatus = .running(activeAIs.count)
        }
    }
    
    deinit {
        stopMonitoring()
        workspaceNotificationCenter.removeObserver(self)
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - IDE Detection Helpers

extension IDEDetector {
    
    /// 获取正在运行的 IDE 数量
    var runningIDECount: Int {
        detectedIDEs.filter { $0.isRunning }.count
    }
    
    /// 获取有 AI 活动的 IDE
    var activeAIIDEs: [IDE] {
        detectedIDEs.filter { $0.aiStatus.isActive }
    }
    
    /// 检查特定 IDE 是否在运行
    func isRunning(_ ideType: IDEType) -> Bool {
        detectedIDEs.first { $0.type == ideType }?.isRunning ?? false
    }
}
