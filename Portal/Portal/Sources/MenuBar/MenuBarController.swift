//
//  MenuBarController.swift
//  Portal
//
//  控制菜单栏图标状态和动画
//

import SwiftUI
import AppKit
import Combine

class MenuBarController: ObservableObject {
    
    // MARK: - Properties
    
    private weak var statusItem: NSStatusItem?
    private var ideDetector: IDEDetector
    private var cancellables = Set<AnyCancellable>()
    
    // 动画计时器
    private var animationTimer: Timer?
    private var animationPhase: CGFloat = 0
    
    // MARK: - Initialization
    
    init(statusItem: NSStatusItem, ideDetector: IDEDetector) {
        self.statusItem = statusItem
        self.ideDetector = ideDetector
        
        setupBindings()
    }
    
    // MARK: - Setup
    
    private func setupBindings() {
        // 监听 AI 状态变化
        ideDetector.$overallStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.updateIcon(for: status)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Icon Updates
    
    private func updateIcon(for status: AIOverallStatus) {
        guard let button = statusItem?.button else { return }
        
        // 停止现有动画
        stopAnimation()
        
        switch status {
        case .idle:
            button.image = createIdleIcon()
            button.contentTintColor = .secondaryLabelColor
            
        case .running(let count):
            button.image = createRunningIcon()
            button.contentTintColor = .systemBlue
            startPulseAnimation()
            
            // 如果多个 AI 同时运行，显示数量
            if count > 1 {
                button.title = "  \(count)"
            } else {
                button.title = ""
            }
            
        case .error:
            button.image = createErrorIcon()
            button.contentTintColor = .systemOrange
            button.title = ""
        }
    }
    
    // MARK: - Icon Creation
    
    private func createIdleIcon() -> NSImage? {
        let image = NSImage(systemSymbolName: "circle.fill", accessibilityDescription: "Portal - 空闲")
        image?.isTemplate = true
        return image
    }
    
    private func createRunningIcon() -> NSImage? {
        let image = NSImage(systemSymbolName: "circle.hexagongrid.fill", accessibilityDescription: "Portal - AI 运行中")
        image?.isTemplate = false
        return image
    }
    
    private func createErrorIcon() -> NSImage? {
        let image = NSImage(systemSymbolName: "exclamationmark.triangle.fill", accessibilityDescription: "Portal - 异常")
        image?.isTemplate = false
        return image
    }
    
    // MARK: - Animation
    
    private func startPulseAnimation() {
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            self?.updatePulseAnimation()
        }
    }
    
    private func stopAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
        animationPhase = 0
        
        // 重置透明度
        statusItem?.button?.alphaValue = 1.0
    }
    
    private func updatePulseAnimation() {
        animationPhase += 0.1
        
        // 使用正弦函数创建平滑的脉动效果
        let alpha = 0.6 + 0.4 * sin(animationPhase)
        statusItem?.button?.alphaValue = CGFloat(alpha)
    }
    
    deinit {
        stopAnimation()
        cancellables.removeAll()
    }
}
