//
//  PortalApp.swift
//  Portal
//
//  AI Status Monitor - macOS 菜单栏 AI 状态监控应用
//  支持 Cursor 和 Antigravity IDE - v1.1
//

import SwiftUI

@main
struct PortalApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        // 设置窗口（通过菜单栏图标访问）
        Settings {
            SettingsView()
        }
    }
}
