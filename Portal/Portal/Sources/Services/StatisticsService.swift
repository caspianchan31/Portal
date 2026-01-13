//
//  StatisticsService.swift
//  Portal
//
//  统计服务 - 管理 AI 调用统计数据
//

import Foundation
import Combine

class StatisticsService: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var todayStatistics: Statistics = .empty
    @Published var weeklyStatistics: Statistics = .empty
    @Published var recentRecords: [CallRecord] = []
    
    // MARK: - Private Properties
    
    private var allRecords: [CallRecord] = []
    private let userDefaults = UserDefaults.standard
    private let recordsKey = "portal_call_records"
    
    // MARK: - Initialization
    
    init() {
        loadRecords()
        updateStatistics()
    }
    
    // MARK: - Public Methods
    
    /// 记录一次 AI 调用
    func recordCall(
        ideType: IDEType,
        duration: TimeInterval,
        status: CallRecordStatus,
        taskName: String? = nil,
        estimatedCost: Decimal? = nil
    ) {
        let record = CallRecord(
            ideType: ideType.rawValue,
            aiProvider: ideType.aiProvider,
            duration: duration,
            status: status,
            taskName: taskName,
            estimatedCost: estimatedCost
        )
        
        allRecords.append(record)
        saveRecords()
        updateStatistics()
    }
    
    /// 清除所有记录
    func clearAllRecords() {
        allRecords.removeAll()
        saveRecords()
        updateStatistics()
    }
    
    /// 获取指定日期范围的统计
    func getStatistics(from startDate: Date, to endDate: Date) -> Statistics {
        let filteredRecords = allRecords.filter { 
            $0.timestamp >= startDate && $0.timestamp <= endDate 
        }
        return calculateStatistics(from: filteredRecords)
    }
    
    // MARK: - Private Methods
    
    private func loadRecords() {
        guard let data = userDefaults.data(forKey: recordsKey),
              let records = try? JSONDecoder().decode([CallRecord].self, from: data) else {
            allRecords = []
            return
        }
        
        // 只保留最近 30 天的记录
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        allRecords = records.filter { $0.timestamp >= thirtyDaysAgo }
    }
    
    private func saveRecords() {
        guard let data = try? JSONEncoder().encode(allRecords) else { return }
        userDefaults.set(data, forKey: recordsKey)
    }
    
    private func updateStatistics() {
        // 今日统计
        let todayStart = Calendar.current.startOfDay(for: Date())
        let todayRecords = allRecords.filter { $0.timestamp >= todayStart }
        todayStatistics = calculateStatistics(from: todayRecords)
        
        // 本周统计
        let weekStart = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let weekRecords = allRecords.filter { $0.timestamp >= weekStart }
        weeklyStatistics = calculateStatistics(from: weekRecords)
        
        // 最近记录（最近 10 条）
        recentRecords = Array(allRecords.suffix(10).reversed())
    }
    
    private func calculateStatistics(from records: [CallRecord]) -> Statistics {
        guard !records.isEmpty else { return .empty }
        
        let totalCalls = records.count
        let totalDuration = records.reduce(0) { $0 + $1.duration }
        let estimatedCost = records.compactMap { $0.estimatedCost }.reduce(0, +)
        let averageDuration = totalDuration / Double(totalCalls)
        
        return Statistics(
            totalCalls: totalCalls,
            totalDuration: totalDuration,
            estimatedCost: estimatedCost,
            averageDuration: averageDuration
        )
    }
}

// MARK: - Formatting Helpers

extension StatisticsService {
    
    /// 格式化持续时间
    static func formatDuration(_ duration: TimeInterval) -> String {
        if duration < 60 {
            return String(format: "%.1f秒", duration)
        } else if duration < 3600 {
            let minutes = Int(duration) / 60
            let seconds = Int(duration) % 60
            return "\(minutes)分\(seconds)秒"
        } else {
            let hours = Int(duration) / 3600
            let minutes = (Int(duration) % 3600) / 60
            return "\(hours)小时\(minutes)分"
        }
    }
    
    /// 格式化成本
    static func formatCost(_ cost: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: cost as NSDecimalNumber) ?? "$0.00"
    }
}
