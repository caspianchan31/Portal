//
//  StatusPopoverView.swift
//  Portal
//
//  状态面板视图 - 点击菜单栏图标时显示
//

import SwiftUI

struct StatusPopoverView: View {
    
    @ObservedObject var ideDetector: IDEDetector
    @ObservedObject var statisticsService: StatisticsService
    
    var body: some View {
        VStack(spacing: 0) {
            // 标题栏
            headerView
            
            Divider()
            
            // IDE 状态列表
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(ideDetector.detectedIDEs) { ide in
                        IDEStatusRow(
                            ide: ide,
                            agentSessions: ide.type == .antigravity 
                                ? ideDetector.getActiveAgentSessions() 
                                : []
                        )
                    }
                }
                .padding()
            }
            
            Divider()
            
            // 今日统计
            todayStatsView
            
            Divider()
            
            // 底部操作栏
            footerView
        }
        .frame(width: 320, height: 400)
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        HStack {
            Image(systemName: "circle.hexagongrid.fill")
                .font(.title2)
                .foregroundColor(.blue)
            
            Text("Portal")
                .font(.headline)
            
            Spacer()
            
            statusBadge
            
            Button {
                openSettings()
            } label: {
                Image(systemName: "gearshape")
                    .font(.body)
            }
            .buttonStyle(.plain)
            .help("设置")
        }
        .padding()
        .background(Color(nsColor: .windowBackgroundColor))
    }
    
    private var statusBadge: some View {
        Group {
            switch ideDetector.overallStatus {
            case .idle:
                Label("空闲", systemImage: "circle.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
            case .running(let count):
                Label("\(count) 个 AI 运行中", systemImage: "circle.hexagongrid.fill")
                    .font(.caption)
                    .foregroundColor(.blue)
            case .error:
                Label("异常", systemImage: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(6)
    }
    
    // MARK: - Today Stats
    
    private var todayStatsView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("今日统计")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack(spacing: 20) {
                StatItem(
                    title: "调用次数",
                    value: "\(statisticsService.todayStatistics.totalCalls)",
                    icon: "arrow.up.arrow.down"
                )
                
                StatItem(
                    title: "总耗时",
                    value: StatisticsService.formatDuration(statisticsService.todayStatistics.totalDuration),
                    icon: "clock"
                )
                
                StatItem(
                    title: "预估成本",
                    value: StatisticsService.formatCost(statisticsService.todayStatistics.estimatedCost),
                    icon: "dollarsign.circle"
                )
            }
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
    }
    
    // MARK: - Footer
    
    private var footerView: some View {
        HStack {
            Button("查看详情") {
                // TODO: 打开详细统计窗口
            }
            .buttonStyle(.plain)
            .font(.caption)
            .foregroundColor(.blue)
            
            Spacer()
            
            Button("退出 Portal") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(.plain)
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding()
    }
    
    // MARK: - Actions
    
    private func openSettings() {
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
    }
}

// MARK: - IDE Status Row

struct IDEStatusRow: View {
    let ide: IDE
    let agentSessions: [AgentSession]
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 主行
            HStack {
                Image(systemName: ide.type.iconName)
                    .font(.title3)
                    .foregroundColor(ide.isRunning ? .blue : .secondary)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(ide.name)
                            .font(.headline)
                        
                        // 显示 Agent 数量 badge
                        if ide.type == .antigravity && ide.totalAgentCount > 0 {
                            Text("\(ide.activeAgentCount)/\(ide.totalAgentCount)")
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(ide.activeAgentCount > 0 ? Color.blue : Color.gray)
                                )
                        }
                    }
                    
                    Text(ide.aiProvider)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                statusIndicator
            }
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            }
            
            // 展开详情
            if isExpanded && ide.isRunning {
                expandedDetails
            }
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(10)
    }
    
    private var statusIndicator: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
            
            Text(statusText)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var statusColor: Color {
        if !ide.isRunning {
            return .gray
        }
        switch ide.aiStatus {
        case .idle:
            return .gray
        case .processing:
            return .blue
        case .completed:
            return .green
        case .error:
            return .orange
        }
    }
    
    private var statusText: String {
        if !ide.isRunning {
            return "未运行"
        }
        return ide.aiStatus.displayText
    }
    
    private var expandedDetails: some View {
        VStack(alignment: .leading, spacing: 8) {
            Divider()
            
            if let lastCall = ide.lastAICallTime {
                DetailRow(label: "最后调用", value: formatTime(lastCall))
            }
            
            DetailRow(label: "状态", value: ide.aiStatus.displayText)
            
            // 显示多 Agent 会话列表
            if ide.type == .antigravity && !agentSessions.isEmpty {
                Divider()
                
                Text("活跃会话")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
                
                ForEach(agentSessions) { session in
                    AgentSessionRow(session: session)
                }
            }
        }
        .padding(.top, 4)
        .transition(.opacity.combined(with: .move(edge: .top)))
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Agent Session Row

struct AgentSessionRow: View {
    let session: AgentSession
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(statusColor)
                .frame(width: 6, height: 6)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(session.currentTask ?? session.taskName ?? "任务")
                    .font(.caption)
                    .lineLimit(1)
                
                Text(session.status.displayText)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // 会话类型标识
            if session.conversationType == .implicit {
                Text("自动")
                    .font(.caption2)
                    .foregroundColor(.orange)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 1)
                    .background(Color.orange.opacity(0.15))
                    .cornerRadius(3)
            }
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
        .cornerRadius(6)
    }
    
    private var statusColor: Color {
        switch session.status {
        case .idle: return .gray
        case .thinking: return .cyan
        case .planning: return .purple
        case .executing: return .blue
        case .completed: return .green
        }
    }
}

// MARK: - Supporting Views

struct StatItem: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.headline)
                .lineLimit(1)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.caption)
        }
    }
}

// MARK: - Preview

#Preview {
    StatusPopoverView(
        ideDetector: IDEDetector(),
        statisticsService: StatisticsService()
    )
}
