#if DEBUG

import SwiftUI

struct MagicAppDemoView: View {
    @State private var appName: String = MagicApp.getAppName()
    @State private var version: String = MagicApp.getVersion()
    @State private var buildNumber: String = MagicApp.getBuildNumber()
    @State private var isICloudEnabled: Bool = MagicApp.isICloudAvailable()
    @State private var deviceName: String = MagicApp.getDeviceName()
    @State private var deviceModel: String = MagicApp.getDeviceModel()
    @State private var systemVersion: String = MagicApp.getSystemVersion()
    @State private var availableStorage: String = MagicApp.getAvailableStorage().map { MagicApp.formatBytes(bytes: $0) } ?? "Unknown"
    @State private var totalStorage: String = MagicApp.getTotalStorage().map { MagicApp.formatBytes(bytes: $0) } ?? "Unknown"
    @State private var iCloudTotalStorage: String = "Unknown"
    @State private var iCloudAvailableStorage: String = "Unknown"
    @State private var bootTime: String = MagicApp.getFormattedBootTime()
    @State private var detailedUptime: String = MagicApp.getDetailedUptimeString()
    @State private var uptimeComponents = MagicApp.getDetailedUptime()
    @State private var appSupportPath: String = MagicApp.getAppSupportDirectory().path
    @State private var appSpecificSupportPath: String = MagicApp.getAppSpecificSupportDirectory().path
    @State private var documentsPath: String = MagicApp.getDocumentsDirectory().path
    @State private var containerPath: String = MagicApp.getContainerDirectory().path
    @State private var cloudContainerPath: String = MagicApp.getCloudContainerDirectory()?.path ?? "iCloud 不可用"
    @State private var cloudDocumentsPath: String = MagicApp.getCloudDocumentsDirectory()?.path ?? "iCloud 不可用"
    @State private var cachePath: String = MagicApp.getCacheDirectory().path
    @State private var databasePath: String = MagicApp.getDatabaseDirectory().path
    @State private var deviceType: String = MagicApp.isDesktop ? "桌面设备" : "移动设备"
    
    // 定时器引用
    @State private var uptimeTimer: Timer? = nil
    
    var body: some View {
        ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 应用信息
                    GroupBox(label: Text("应用信息")) {
                        VStack(alignment: .leading, spacing: 8) {
                            LabeledContent("应用名称", value: appName)
                            LabeledContent("版本", value: version)
                            LabeledContent("构建号", value: buildNumber)
                            LabeledContent("Bundle ID", value: MagicApp.getBundleIdentifier())
                            LabeledContent("设备类型", value: deviceType)
                        }
                        .padding(.top, 4)
                    }

                    // 设备信息
                    GroupBox(label: Text("设备信息")) {
                        VStack(alignment: .leading, spacing: 8) {
                            LabeledContent("设备名称", value: deviceName)
                            LabeledContent("设备型号", value: deviceModel)
                            LabeledContent("系统版本", value: systemVersion)
                            Divider()
                            Group {
                                LabeledContent("是否为 iPhone", value: MagicApp.isiPhone ? "是" : "否")
                                LabeledContent("是否为 iPad", value: MagicApp.isiPad ? "是" : "否")
                                LabeledContent("是否为 Mac", value: MagicApp.isMac ? "是" : "否")
                                LabeledContent("是否为 Watch", value: MagicApp.isWatch ? "是" : "否")
                                LabeledContent("是否为 TV", value: MagicApp.isTV ? "是" : "否")
                                if #available(iOS 17.0, *) {
                                    LabeledContent("是否为 Vision", value: MagicApp.isVision ? "是" : "否")
                                }
                            }
                        }
                        .padding(.top, 4)
                    }

                    // 存储信息
                    GroupBox(label: Text("存储信息")) {
                        VStack(alignment: .leading, spacing: 8) {
                            LabeledContent("可用空间", value: availableStorage)
                            LabeledContent("总空间", value: totalStorage)
                        }
                        .padding(.top, 4)
                    }

                    // iCloud 状态
                    GroupBox(label: Text("iCloud 状态")) {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("iCloud Drive")
                                Spacer()
                                Text(isICloudEnabled ? "已启用" : "未启用")
                                    .foregroundColor(isICloudEnabled ? .green : .red)
                            }
                            
                            LabeledContent("总容量", value: iCloudTotalStorage)
                            LabeledContent("可用容量", value: iCloudAvailableStorage)
                        }
                        .padding(.top, 4)
                    }

                    // iCloud 目录信息
                    GroupBox(label: Text("iCloud 目录")) {
                        VStack(alignment: .leading, spacing: 8) {
                            // Cloud Container
                            Text("iCloud Container:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            if let containerURL = MagicApp.getCloudContainerDirectory() {
                                HStack {
                                    Text(cloudContainerPath)
                                        .font(.caption2)
                                        .textSelection(.enabled)
                                    Spacer()
                                    containerURL.makeOpenButton()
                                }
                            } else {
                                Text(cloudContainerPath)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            
                            Divider()
                            
                            // Cloud Documents
                            Text("iCloud Documents:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            if let documentsURL = MagicApp.getCloudDocumentsDirectory() {
                                HStack {
                                    Text(cloudDocumentsPath)
                                        .font(.caption2)
                                        .textSelection(.enabled)
                                    Spacer()
                                    documentsURL.makeOpenButton()
                                }
                            } else {
                                Text(cloudDocumentsPath)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.top, 4)
                    }

                    // 应用目录信息
                    GroupBox(label: Text("应用目录")) {
                        VStack(alignment: .leading, spacing: 8) {
                            // Container
                            Text("Container:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            HStack {
                                Text(containerPath)
                                    .font(.caption2)
                                    .textSelection(.enabled)
                                Spacer()
                                URL(fileURLWithPath: containerPath)
                                    .makeOpenButton()
                            }
                            
                            Divider()
                            
                            // Documents
                            Text("Documents:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            HStack {
                                Text(documentsPath)
                                    .font(.caption2)
                                    .textSelection(.enabled)
                                Spacer()
                                URL(fileURLWithPath: documentsPath)
                                    .makeOpenButton()
                            }
                            
                            Divider()
                            
                            // Application Support
                            Text("Application Support:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            HStack {
                                Text(appSupportPath)
                                    .font(.caption2)
                                    .textSelection(.enabled)
                                Spacer()
                                URL(fileURLWithPath: appSupportPath)
                                    .makeOpenButton()
                            }
                            
                            Divider()
                            
                            // App Specific Support
                            Text("App Specific Support:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            HStack {
                                Text(appSpecificSupportPath)
                                    .font(.caption2)
                                    .textSelection(.enabled)
                                Spacer()
                                URL(fileURLWithPath: appSpecificSupportPath)
                                    .makeOpenButton()
                            }
                            
                            Divider()
                            
                            // Database Directory
                            Text("Database:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            HStack {
                                Text(databasePath)
                                    .font(.caption2)
                                    .textSelection(.enabled)
                                Spacer()
                                URL(fileURLWithPath: databasePath)
                                    .makeOpenButton()
                            }
                            
                            Divider()
                            
                            // Cache Directory
                            Text("Cache:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            HStack {
                                Text(cachePath)
                                    .font(.caption2)
                                    .textSelection(.enabled)
                                Spacer()
                                URL(fileURLWithPath: cachePath)
                                    .makeOpenButton()
                            }
                        }
                        .padding(.top, 4)
                    }

                    // 系统运行时间信息
                    GroupBox {
                        VStack(alignment: .leading, spacing: 12) {
                            // 标题部分
                            HStack {
                                Image(systemName: "clock")
                                    .foregroundColor(.accentColor)
                                Text("系统运行时间")
                                    .font(.headline)
                            }
                            
                            Divider()
                            
                            // 启动时间
                            VStack(alignment: .leading, spacing: 8) {
                                LabeledContent("系统启动于", value: bootTime)
                                LabeledContent("已运行", value: detailedUptime)
                            }
                            
                            Divider()
                            
                            // 运行时间组件
                            HStack(spacing: 16) {
                                TimeComponentView(value: uptimeComponents.days, unit: "天")
                                TimeComponentView(value: uptimeComponents.hours, unit: "小时")
                                TimeComponentView(value: uptimeComponents.minutes, unit: "分钟")
                                TimeComponentView(value: uptimeComponents.seconds, unit: "秒")
                            }
                            
                            // 今日运行时间进度条
                            VStack(alignment: .leading, spacing: 4) {
                                let hoursProgress = (Double(uptimeComponents.hours) + 
                                                   Double(uptimeComponents.minutes) / 60.0) / 24.0
                                
                                HStack {
                                    Text("今日运行时间")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text(String(format: "%.1f小时", hoursProgress * 24))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                ProgressView(value: hoursProgress)
                                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                            }
                        }
                        .padding()
                    }

                    // 退出按钮
                    Button("退出应用", role: .destructive) {
                        MagicApp.quit()
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 20)
                }
                .padding()
            }
        .onAppear {
            // 启动定时器，每秒更新一次
            startUptimeTimer()
        }
        .onDisappear {
            // 清理定时器
            stopUptimeTimer()
        }
    }
    
    @MainActor
    private func getICloudStorageInfo() async {
        // 获取 iCloud 总容量
        do {
            let total = try MagicApp.getICloudTotalStorage()
            iCloudTotalStorage = MagicApp.formatBytes(bytes: total)
        } catch let error as iCloudStorageError {
            iCloudTotalStorage = error.localizedDescription
        } catch {
            iCloudTotalStorage = "未知错误: \(error.localizedDescription)"
        }
        
        // 获取 iCloud 可用容量
        do {
            let available = try MagicApp.getICloudAvailableStorage()
            iCloudAvailableStorage = MagicApp.formatBytes(bytes: available)
        } catch let error as iCloudStorageError {
            iCloudAvailableStorage = error.localizedDescription
        } catch {
            iCloudAvailableStorage = "未知错误: \(error.localizedDescription)"
        }
    }
    
    private func startUptimeTimer() {
        // 确保只创建一个定时器
        stopUptimeTimer()
        
        // 创建新的定时器，每秒更新一次
        uptimeTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            updateUptimeInfo()
        }
    }
    
    private func stopUptimeTimer() {
        uptimeTimer?.invalidate()
        uptimeTimer = nil
    }
    
    private func updateUptimeInfo() {
        detailedUptime = MagicApp.getDetailedUptimeString()
        uptimeComponents = MagicApp.getDetailedUptime()
    }
}

// 时间组件视图
struct TimeComponentView: View {
    let value: Int
    let unit: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.accentColor)
            Text(unit)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(minWidth: 60)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.accentColor.opacity(0.1))
        )
    }
}

#if DEBUG
#Preview("MagicApp 功能演示") {
    MagicAppDemoView()
}
#endif

#endif
