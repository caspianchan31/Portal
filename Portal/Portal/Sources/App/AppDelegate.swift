//
//  AppDelegate.swift
//  Portal
//
//  负责菜单栏图标和应用生命周期管理
//

import SwiftUI
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    
    // MARK: - Properties
    
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private var menuBarController: MenuBarController?
    
    // 刘海指示器
    private var notchStatusController: NotchStatusController?
    
    // 服务
    private var ideDetector: IDEDetector?
    private var statisticsService: StatisticsService?
    
    // MARK: - App Lifecycle
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 隐藏 Dock 图标
        NSApp.setActivationPolicy(.accessory)
        
        // 初始化服务
        setupServices()
        
        // 设置菜单栏
        setupMenuBar()
        
        // 设置刘海指示器
        setupNotchIndicator()
        
        // 开始监控
        startMonitoring()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        stopMonitoring()
        notchStatusController?.hideNotchIndicator()
    }
    
    // MARK: - Setup
    
    private func setupServices() {
        ideDetector = IDEDetector()
        statisticsService = StatisticsService()
    }
    
    private func setupMenuBar() {
        // 创建菜单栏图标
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "circle.fill", accessibilityDescription: "Portal")
            button.image?.isTemplate = true
            button.action = #selector(togglePopover)
            button.target = self
        }
        
        // 创建弹出面板
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 320, height: 400)
        popover?.behavior = .transient
        popover?.animates = true
        
        // 设置面板内容
        let contentView = StatusPopoverView(
            ideDetector: ideDetector!,
            statisticsService: statisticsService!
        )
        popover?.contentViewController = NSHostingController(rootView: contentView)
        
        // 创建菜单栏控制器
        menuBarController = MenuBarController(
            statusItem: statusItem!,
            ideDetector: ideDetector!
        )
    }
    
    private func setupNotchIndicator() {
        // 创建刘海区域状态指示器
        notchStatusController = NotchStatusController(ideDetector: ideDetector!)
        notchStatusController?.showNotchIndicator()
    }
    
    private func startMonitoring() {
        ideDetector?.startMonitoring()
    }
    
    private func stopMonitoring() {
        ideDetector?.stopMonitoring()
    }
    
    // MARK: - Actions
    
    @objc private func togglePopover() {
        guard let popover = popover,
              let button = statusItem?.button else { return }
        
        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            
            // 确保面板获得焦点
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}
