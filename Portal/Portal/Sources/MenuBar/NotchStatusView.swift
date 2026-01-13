//
//  NotchStatusView.swift
//  Portal
//
//  刘海一体化状态指示器 - 精致 UI 设计
//

import SwiftUI
import AppKit
import Combine

/// 刘海状态窗口控制器
class NotchStatusController: ObservableObject {
    
    private var statusWindow: NSWindow?
    private var ideDetector: IDEDetector
    
    private let panelWidth: CGFloat = 300
    private let panelHeight: CGFloat = 160
    
    init(ideDetector: IDEDetector) {
        self.ideDetector = ideDetector
    }
    
    func showNotchIndicator() {
        guard hasNotch() else {
            print("[Portal] 此设备没有刘海，跳过刘海指示器")
            return
        }
        createNotchWindow()
    }
    
    func hideNotchIndicator() {
        statusWindow?.close()
        statusWindow = nil
    }
    
    private func hasNotch() -> Bool {
        guard let screen = NSScreen.main else { return false }
        if #available(macOS 12.0, *) {
            return screen.auxiliaryTopLeftArea != nil || screen.auxiliaryTopRightArea != nil
        }
        return false
    }
    
    private func createNotchWindow() {
        guard let screen = NSScreen.main else { return }
        
        let screenFrame = screen.frame
        let x = screenFrame.midX - panelWidth / 2
        let y = screenFrame.maxY - panelHeight
        
        let window = NSWindow(
            contentRect: NSRect(x: x, y: y, width: panelWidth, height: panelHeight),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        window.isOpaque = false
        window.backgroundColor = .clear
        window.level = .screenSaver
        window.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        window.hasShadow = false
        
        let contentView = NotchPanelView(
            ideDetector: ideDetector,
            width: panelWidth,
            height: panelHeight
        )
        window.contentView = NSHostingView(rootView: contentView)
        
        window.orderFront(nil)
        statusWindow = window
        
        print("[Portal] 刘海悬停面板已启用")
    }
    
    deinit {
        hideNotchIndicator()
    }
}

// MARK: - Notch Panel View

struct NotchPanelView: View {
    @ObservedObject var ideDetector: IDEDetector
    
    let width: CGFloat
    let height: CGFloat
    
    @State private var isHovering = false
    @State private var pulse: CGFloat = 1.0
    
    private let notchHeight: CGFloat = 34
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .top) {
                if isHovering {
                    panelBackground
                        .overlay(panelContent)
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .scale(scale: 0.98, anchor: .top)),
                            removal: .opacity
                        ))
                }
                
                // 悬停检测区
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: notchHeight)
                    .contentShape(Rectangle())
            }
            Spacer()
        }
        .frame(width: width, height: height)
        .onHover { hovering in
            withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
                isHovering = hovering
            }
        }
        .onAppear { startPulseIfNeeded() }
        .onChange(of: isRunning) { _ in startPulseIfNeeded() }
    }
    
    // MARK: - Panel Background
    
    private var panelBackground: some View {
        ZStack {
            VStack(spacing: 0) {
                Rectangle()
                    .fill(Color.black)
                    .frame(height: notchHeight)
                UnevenRoundedRectangle(
                    topLeadingRadius: 0,
                    bottomLeadingRadius: 22,
                    bottomTrailingRadius: 22,
                    topTrailingRadius: 0
                )
                .fill(Color.black)
            }
        }
        .shadow(color: Color.black.opacity(0.5), radius: 30, y: 15)
    }
    
    // MARK: - Panel Content
    
    private var panelContent: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: notchHeight + 12)
            
            VStack(spacing: 12) {
                // Header
                headerView
                
                // Divider
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.clear, .white.opacity(0.15), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 0.5)
                
                // IDE List
                ideListView
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 18)
        }
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        HStack(spacing: 10) {
            // Logo with pulse
            ZStack {
                if isRunning {
                    Circle()
                        .fill(statusColor.opacity(0.25))
                        .frame(width: 20, height: 20)
                        .scaleEffect(pulse)
                    Circle()
                        .fill(statusColor.opacity(0.15))
                        .frame(width: 28, height: 28)
                        .scaleEffect(pulse * 0.9)
                }
                Circle()
                    .fill(statusColor)
                    .frame(width: 10, height: 10)
                    .shadow(color: statusColor.opacity(0.5), radius: 4)
            }
            
            Text("Portal")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
            
            Spacer()
            
            // Status badge
            Text(statusText)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(statusColor)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(statusColor.opacity(0.15))
                )
        }
    }
    
    // MARK: - IDE List
    
    private var ideListView: some View {
        VStack(spacing: 8) {
            if runningIDEs.isEmpty {
                HStack {
                    Image(systemName: "moon.zzz")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.3))
                    Text("暂无运行的 IDE")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.4))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            } else {
                ForEach(runningIDEs) { ide in
                    ideRow(ide)
                }
            }
        }
    }
    
    // MARK: - IDE Row
    
    private func ideRow(_ ide: IDE) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 12) {
                // IDE Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 28, height: 28)
                    Image(systemName: ide.type.iconName)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                // IDE Name
                VStack(alignment: .leading, spacing: 2) {
                    Text(ide.name)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.95))
                    
                    // 显示多 Agent 信息
                    if ide.type == .antigravity && ide.totalAgentCount > 0 {
                        Text("\(ide.activeAgentCount)/\(ide.totalAgentCount) Agents")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.4))
                    }
                }
                
                Spacer()
                
                // Status
                HStack(spacing: 5) {
                    Circle()
                        .fill(ideStatusColor(ide))
                        .frame(width: 6, height: 6)
                        .shadow(color: ideStatusColor(ide).opacity(0.5), radius: 2)
                    
                    Text(ide.aiStatus.displayText)
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.5))
                        .lineLimit(1)
                }
            }
            
            // 如果有活跃的 Agent，显示当前任务
            if ide.type == .antigravity && ide.aiStatus.isActive {
                if let sessions = getActiveAgentSessions(), !sessions.isEmpty {
                    ForEach(sessions.prefix(2)) { session in
                        agentSessionRow(session)
                    }
                    if sessions.count > 2 {
                        Text("+ \(sessions.count - 2) more...")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.3))
                            .padding(.leading, 40)
                    }
                }
            }
        }
        .padding(.vertical, 2)
    }
    
    // MARK: - Agent Session Row
    
    private func agentSessionRow(_ session: AgentSession) -> some View {
        HStack(spacing: 8) {
            Rectangle()
                .fill(Color.white.opacity(0.15))
                .frame(width: 1, height: 16)
                .padding(.leading, 40)
            
            Circle()
                .fill(session.status.isActive ? Color.cyan : Color.gray)
                .frame(width: 4, height: 4)
            
            Text(session.currentTask ?? session.taskName ?? "任务")
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.5))
                .lineLimit(1)
        }
    }
    
    private func getActiveAgentSessions() -> [AgentSession]? {
        return ideDetector.getActiveAgentSessions()
    }
    
    // MARK: - Helpers
    
    private var runningIDEs: [IDE] {
        ideDetector.detectedIDEs.filter { $0.isRunning }
    }
    
    private var isRunning: Bool {
        if case .running = ideDetector.overallStatus { return true }
        return false
    }
    
    private var statusColor: Color {
        switch ideDetector.overallStatus {
        case .idle: return Color(red: 0.6, green: 0.6, blue: 0.65)
        case .running: return Color(red: 0.3, green: 0.6, blue: 1.0)
        case .error: return Color(red: 1.0, green: 0.6, blue: 0.3)
        }
    }
    
    private var statusText: String {
        switch ideDetector.overallStatus {
        case .idle: return "空闲"
        case .running(let n): return "\(n) AI"
        case .error: return "异常"
        }
    }
    
    private func ideStatusColor(_ ide: IDE) -> Color {
        switch ide.aiStatus {
        case .idle: return Color(red: 0.5, green: 0.5, blue: 0.55)
        case .processing: return Color(red: 0.3, green: 0.6, blue: 1.0)
        case .completed: return Color(red: 0.3, green: 0.85, blue: 0.5)
        case .error: return Color(red: 1.0, green: 0.5, blue: 0.3)
        }
    }
    
    private func startPulseIfNeeded() {
        if isRunning {
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                pulse = 1.3
            }
        } else {
            withAnimation(.easeOut(duration: 0.3)) { pulse = 1.0 }
        }
    }
}
