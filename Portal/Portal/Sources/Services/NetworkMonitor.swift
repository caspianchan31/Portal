//
//  NetworkMonitor.swift
//  Portal
//
//  网络监控服务（简化版）
//
//  注意：Antigravity 的 AI 状态检测已由 ArtifactsMonitor 接管
//  此文件保留基本结构，以备将来可能的网络监控需求
//

import Foundation
import Combine

/// AI API 调用事件
struct AIAPIEvent {
    let ideType: IDEType
    let apiDomain: String
    let startTime: Date
    var endTime: Date?
    var isActive: Bool
    var activeAgentCount: Int = 0
    var totalAgentCount: Int = 0
    
    var duration: TimeInterval {
        (endTime ?? Date()).timeIntervalSince(startTime)
    }
}

class NetworkMonitor: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var activeAIEvents: [IDEType: AIAPIEvent] = [:]
    
    // MARK: - Initialization
    
    init() {}
    
    // MARK: - Public Methods
    
    func startMonitoring() {
        // 简化版：暂时不启动网络监控
        // Antigravity 使用 ArtifactsMonitor
        // Cursor 使用 LogParser
        print("[Portal] NetworkMonitor 已简化，不执行网络监控")
    }
    
    func stopMonitoring() {
        // 无需清理
    }
    
    /// 检查特定 IDE 是否有活跃的 AI 调用（保留接口兼容）
    func isAIActive(for ideType: IDEType) -> Bool {
        return activeAIEvents[ideType]?.isActive ?? false
    }
    
    /// 获取特定 IDE 的当前 AI 调用时长
    func currentDuration(for ideType: IDEType) -> TimeInterval? {
        guard let event = activeAIEvents[ideType], event.isActive else {
            return nil
        }
        return event.duration
    }
    
    /// 获取活跃的 Agent 数量（保留接口兼容）
    func getActiveAgentCount() -> Int {
        return 0
    }
    
    /// 获取总 Agent 数量（保留接口兼容）
    func getTotalAgentCount() -> Int {
        return 0
    }
    
    deinit {
        stopMonitoring()
    }
}

// MARK: - Notifications

extension Notification.Name {
    static let aiCallCompleted = Notification.Name("portal.aiCallCompleted")
    static let aiCallStarted = Notification.Name("portal.aiCallStarted")
}
