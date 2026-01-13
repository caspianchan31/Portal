//
//  SettingsView.swift
//  Portal
//
//  设置视图
//

import SwiftUI

struct SettingsView: View {
    
    @AppStorage("launchAtLogin") private var launchAtLogin = false
    @AppStorage("showInDock") private var showInDock = false
    @AppStorage("monitoringInterval") private var monitoringInterval = 1.0
    @AppStorage("enableNotifications") private var enableNotifications = true
    @AppStorage("costWarningThreshold") private var costWarningThreshold = 5.0
    
    var body: some View {
        TabView {
            generalSettingsView
                .tabItem {
                    Label("通用", systemImage: "gearshape")
                }
            
            ideSettingsView
                .tabItem {
                    Label("IDE", systemImage: "terminal")
                }
            
            notificationSettingsView
                .tabItem {
                    Label("通知", systemImage: "bell")
                }
            
            aboutView
                .tabItem {
                    Label("关于", systemImage: "info.circle")
                }
        }
        .frame(width: 450, height: 300)
    }
    
    // MARK: - General Settings
    
    private var generalSettingsView: some View {
        Form {
            Section {
                Toggle("开机自动启动", isOn: $launchAtLogin)
                Toggle("在 Dock 中显示", isOn: $showInDock)
                    .onChange(of: showInDock) { newValue in
                        updateDockPresence(newValue)
                    }
            }
            
            Section {
                Picker("监控频率", selection: $monitoringInterval) {
                    Text("高 (0.5秒)").tag(0.5)
                    Text("中 (1秒)").tag(1.0)
                    Text("低 (2秒)").tag(2.0)
                }
                .pickerStyle(.segmented)
                
                Text("更高的频率会更实时，但会略微增加资源占用")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .formStyle(.grouped)
        .padding()
    }
    
    // MARK: - IDE Settings
    
    private var ideSettingsView: some View {
        Form {
            Section("支持的 IDE") {
                ForEach(IDEType.allCases) { ideType in
                    IDESettingRow(ideType: ideType)
                }
            }
            
            Section {
                Text("更多 IDE 支持即将推出")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .formStyle(.grouped)
        .padding()
    }
    
    // MARK: - Notification Settings
    
    private var notificationSettingsView: some View {
        Form {
            Section {
                Toggle("启用通知", isOn: $enableNotifications)
            }
            
            if enableNotifications {
                Section("通知触发条件") {
                    Toggle("AI 长时间运行 (>30秒)", isOn: .constant(true))
                    Toggle("API 错误", isOn: .constant(true))
                    Toggle("每日成本超限", isOn: .constant(true))
                }
                
                Section("成本预警") {
                    HStack {
                        Text("每日成本上限")
                        Spacer()
                        TextField("", value: $costWarningThreshold, format: .currency(code: "USD"))
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 100)
                    }
                }
            }
        }
        .formStyle(.grouped)
        .padding()
    }
    
    // MARK: - About
    
    private var aboutView: some View {
        VStack(spacing: 16) {
            Image(systemName: "circle.hexagongrid.fill")
                .font(.system(size: 64))
                .foregroundColor(.blue)
            
            Text("Portal")
                .font(.title)
                .fontWeight(.bold)
            
            Text("AI Status Monitor")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("版本 1.0.0")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            HStack(spacing: 20) {
                Link("GitHub", destination: URL(string: "https://github.com/caspianchan31/Portal")!)
                Link("反馈问题", destination: URL(string: "https://github.com/caspianchan31/Portal/issues")!)
            }
            .font(.caption)
            
            Text("© 2026 Portal Team")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
    }
    
    // MARK: - Helper Methods
    
    private func updateDockPresence(_ show: Bool) {
        NSApp.setActivationPolicy(show ? .regular : .accessory)
    }
}

// MARK: - IDE Setting Row

struct IDESettingRow: View {
    let ideType: IDEType
    @State private var isEnabled = true
    
    var body: some View {
        HStack {
            Image(systemName: ideType.iconName)
                .frame(width: 24)
            
            VStack(alignment: .leading) {
                Text(ideType.rawValue)
                Text(ideType.aiProvider)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isEnabled)
                .labelsHidden()
        }
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
}
