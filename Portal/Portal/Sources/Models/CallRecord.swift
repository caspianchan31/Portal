//
//  CallRecord.swift
//  Portal
//
//  AI 调用记录模型
//

import Foundation

/// AI 调用记录
struct CallRecord: Identifiable, Codable {
    let id: UUID
    let ideType: String        // IDE 类型
    let aiProvider: String     // AI 提供商
    let timestamp: Date        // 调用时间
    let duration: TimeInterval // 耗时（秒）
    let status: CallRecordStatus
    let estimatedCost: Decimal? // 预估成本（可选）
    let taskName: String?       // 任务名称 (from Extension)
    
    init(
        id: UUID = UUID(),
        ideType: String,
        aiProvider: String,
        timestamp: Date = Date(),
        duration: TimeInterval,
        status: CallRecordStatus,
        taskName: String? = nil,
        estimatedCost: Decimal? = nil
    ) {
        self.id = id
        self.ideType = ideType
        self.aiProvider = aiProvider
        self.timestamp = timestamp
        self.duration = duration
        self.status = status
        self.taskName = taskName
        self.estimatedCost = estimatedCost
    }
}

/// 调用状态
enum CallRecordStatus: String, Codable {
    case success
    case failed
    case timeout
}

/// 统计数据
struct Statistics {
    let totalCalls: Int
    let totalDuration: TimeInterval
    let estimatedCost: Decimal
    let averageDuration: TimeInterval
    
    static let empty = Statistics(
        totalCalls: 0,
        totalDuration: 0,
        estimatedCost: 0,
        averageDuration: 0
    )
}

/// 每日统计
struct DailyStatistics: Identifiable {
    let id = UUID()
    let date: Date
    let statistics: Statistics
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd"
        return formatter.string(from: date)
    }
}
