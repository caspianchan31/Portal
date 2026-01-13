//
//  IDE.swift
//  Portal
//
//  IDE 数据模型
//

import Foundation

/// 支持的 IDE 类型
enum IDEType: String, CaseIterable, Identifiable {
    case cursor = "Cursor"
    case antigravity = "Antigravity"
    case vscode = "VS Code"
    case jetbrains = "JetBrains"
    
    var id: String { rawValue }
    
    /// Bundle ID 用于检测进程
    var bundleIdentifier: String {
        switch self {
        case .cursor:
            return "com.todesktop.230313mzl4w4u92"  // Cursor 的实际 Bundle ID
        case .antigravity:
            return "com.google.antigravity"  // 正确的 Bundle ID
        case .vscode:
            return "com.microsoft.VSCode"
        case .jetbrains:
            return "com.jetbrains.intellij"  // IntelliJ IDEA，其他 IDE 类似
        }
    }
    
    /// 关联的 AI 服务
    var aiProvider: String {
        switch self {
        case .cursor:
            return "Anthropic Claude"
        case .antigravity:
            return "Google Gemini"
        case .vscode:
            return "GitHub Copilot"
        case .jetbrains:
            return "JetBrains AI"
        }
    }
    
    /// 监控的 API 域名
    var apiDomains: [String] {
        switch self {
        case .cursor:
            return ["api.anthropic.com", "api.openai.com"]
        case .antigravity:
            return ["generativelanguage.googleapis.com", "aiplatform.googleapis.com"]
        case .vscode:
            return ["api.github.com", "copilot.github.com"]
        case .jetbrains:
            return ["ai.jetbrains.com"]
        }
    }
    
    /// 图标名称
    var iconName: String {
        switch self {
        case .cursor:
            return "cursorarrow.rays"
        case .antigravity:
            return "sparkles"
        case .vscode:
            return "chevron.left.forwardslash.chevron.right"
        case .jetbrains:
            return "hammer.fill"
        }
    }
}

/// IDE 实例
struct IDE: Identifiable {
    let id = UUID()
    let type: IDEType
    var processId: pid_t?
    var isRunning: Bool = false
    var aiStatus: AIStatus = .idle
    var lastAICallTime: Date?
    var activeAgentCount: Int = 0   // 活跃的 Agent 数量
    var totalAgentCount: Int = 0    // 总 Agent 数量
    
    var name: String { type.rawValue }
    var aiProvider: String { type.aiProvider }
}

/// AI 运行状态
enum AIStatus: Equatable {
    case idle                   // 空闲
    case processing(String?)    // 处理中，可选的任务描述
    case completed(TimeInterval) // 完成，耗时
    case error(String)          // 错误
    
    var isActive: Bool {
        switch self {
        case .processing: return true
        default: return false
        }
    }
    
    var displayText: String {
        switch self {
        case .idle:
            return "空闲"
        case .processing(let task):
            return task ?? "处理中..."
        case .completed(let duration):
            return String(format: "完成 (%.1fs)", duration)
        case .error(let message):
            return "错误: \(message)"
        }
    }
}

/// 总体 AI 状态
enum AIOverallStatus: Equatable {
    case idle           // 所有 IDE 都空闲
    case running(Int)   // 有 AI 在运行，参数是运行中的数量
    case error          // 有错误
}
