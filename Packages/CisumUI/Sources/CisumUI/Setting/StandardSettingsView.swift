import SwiftUI

/// 符合 iOS Human Interface Guidelines 的标准设置视图示例
///
/// 此视图展示了 iOS 设置应用的标准 UI 模式和最佳实践：
/// - 使用 `.listStyle(.insetGrouped)` 样式
/// - 使用原生的 `List` 和 `Section`
/// - 遵循 iOS 的间距、字体和颜色规范
/// - 不添加自定义手势，避免与滚动冲突
public struct StandardSettingsView: View {
    // MARK: - State

    @State private var airplaneMode = false
    @State private var wifiEnabled = true
    @State private var bluetoothEnabled = false
    @State private var notificationsEnabled = true
    @State private var soundEnabled = true
    @State private var selectedTheme = 0
    @State private var selectedLanguage = 0
    @State private var autoUpdate = true
    @State private var selectedDistanceUnit = 0

    // MARK: - Data

    private let themes = ["跟随系统", "浅色", "深色"]
    private let languages = ["简体中文", "English", "日本語"]
    private let distanceUnits = ["公里", "英里"]

    // MARK: - Body

    public var body: some View {
        List {
            // MARK: - Section 1: 连接设置（带图标和 Toggle）
            Section("连接") {
                // 飞行模式 - 红色图标强调
                HStack(spacing: 16) {
                    Image(systemName: "airplane")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.red)
                        .frame(width: 29, height: 29)
                    Text("飞行模式")
                    Spacer()
                    Toggle("", isOn: $airplaneMode)
                        .labelsHidden()
                }

                // Wi-Fi
                HStack(spacing: 16) {
                    Image(systemName: "wifi")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.blue)
                        .frame(width: 29, height: 29)
                    Text("Wi-Fi")
                    Spacer()
                    HStack(spacing: 4) {
                        Text("MyHome-5G")
                            .foregroundColor(.secondary)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        // Navigate to Wi-Fi settings
                    }
                }

                // 蓝牙
                HStack(spacing: 16) {
                    Image(systemName: "bluetooth")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.blue)
                        .frame(width: 29, height: 29)
                    Text("蓝牙")
                    Spacer()
                    HStack(spacing: 4) {
                        Text("开启")
                            .foregroundColor(.secondary)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        // Navigate to Bluetooth settings
                    }
                }
            }

            // MARK: - Section 2: 通知设置（Toggle + 描述）
            Section("通知") {
                // 主开关
                HStack(spacing: 16) {
                    Image(systemName: "bell.badge")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.red)
                        .frame(width: 29, height: 29)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("允许通知")
                        Text("接收应用推送的通知")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Toggle("", isOn: $notificationsEnabled)
                        .labelsHidden()
                }

                // 声音（依赖主开关）
                HStack(spacing: 16) {
                    Image(systemName: "speaker.wave.2")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.orange)
                        .frame(width: 29, height: 29)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("声音")
                        Text("通知提示音")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Toggle("", isOn: $soundEnabled)
                        .labelsHidden()
                        .disabled(!notificationsEnabled)
                }
            }

            // MARK: - Section 3: 通用设置（NavigationLink）
            Section("通用") {
                // 关于本机
                NavigationLink(destination: Text("关于本机详情")) {
                    HStack(spacing: 16) {
                        Image(systemName: "info.circle")
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.blue)
                            .frame(width: 29, height: 29)
                        Text("关于本机")
                    }
                }

                // 软件更新
                NavigationLink(destination: Text("软件更新详情")) {
                    HStack(spacing: 16) {
                        Image(systemName: "app.badge")
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.blue)
                            .frame(width: 29, height: 29)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("软件更新")
                            Text("iOS 17.2")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }

            // MARK: - Section 4: 外观（Picker）
            Section("外观") {
                // 主题选择
                Picker("主题", selection: $selectedTheme) {
                    ForEach(0..<themes.count, id: \.self) { index in
                        Text(themes[index])
                            .tag(index)
                    }
                }
                .pickerStyle(.inline)

                // 语言
                HStack(spacing: 16) {
                    Image(systemName: "globe")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.green)
                        .frame(width: 29, height: 29)
                    Text("语言")
                    Spacer()
                    HStack(spacing: 4) {
                        Text(languages[selectedLanguage])
                            .foregroundColor(.secondary)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                }
            }

            // MARK: - Section 5: 隐私与安全
            Section("隐私与安全") {
                // 定位服务
                HStack(spacing: 16) {
                    Image(systemName: "location.fill")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.green)
                        .frame(width: 29, height: 29)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("定位服务")
                        Text("使用应用时")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                }

                // 面容 ID
                HStack(spacing: 16) {
                    Image(systemName: "faceid")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.green)
                        .frame(width: 29, height: 29)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("面容 ID")
                        Text("已设置")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Toggle("", isOn: .constant(true))
                        .labelsHidden()
                }
            }

            // MARK: - Section 6: 信息展示
            Section("设备信息") {
                // 设备名称
                HStack(spacing: 16) {
                    Image(systemName: "iphone")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.gray)
                        .frame(width: 29, height: 29)
                    Text("名称")
                    Spacer()
                    Text("iPhone 15 Pro")
                        .foregroundColor(.secondary)
                }

                // 型号
                HStack(spacing: 16) {
                    Image(systemName: "info.circle")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.gray)
                        .frame(width: 29, height: 29)
                    Text("型号")
                    Spacer()
                    Text("A2849")
                        .foregroundColor(.secondary)
                }

                // 系统版本
                HStack(spacing: 16) {
                    Image(systemName: "gear")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.gray)
                        .frame(width: 29, height: 29)
                    Text("版本")
                    Spacer()
                    Text("iOS 17.2.1")
                        .foregroundColor(.secondary)
                }
            }

            // MARK: - Section 7: 高级选项
            Section("高级") {
                // 自动更新
                HStack(spacing: 16) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.blue)
                        .frame(width: 29, height: 29)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("自动更新")
                        Text("自动下载最新的 iOS 更新")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Toggle("", isOn: $autoUpdate)
                        .labelsHidden()
                }

                // 距离单位
                Picker("距离单位", selection: $selectedDistanceUnit) {
                    ForEach(0..<distanceUnits.count, id: \.self) { index in
                        Text(distanceUnits[index])
                            .tag(index)
                    }
                }
                #if os(iOS)
                .pickerStyle(.navigationLink)
                #endif
            }
        }
        #if os(iOS)
        .listStyle(.insetGrouped)  // ✅ iOS 标准样式
        #else
        .listStyle(.inset(alternatesRowBackgrounds: true))
        #endif
        .navigationTitle("设置")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
    }
}

// MARK: - Preview

#if DEBUG
#Preview("标准设置视图") {
    NavigationView {
        StandardSettingsView()
    }
}

#Preview("深色模式") {
    NavigationView {
        StandardSettingsView()
    }
    .preferredColorScheme(.dark)
}

#if os(iOS)
#Preview("组件示例") {
    ScrollView {
        VStack(spacing: 24) {
            // 示例 1: 基本 Section
            VStack(alignment: .leading, spacing: 8) {
                Text("基本 Section")
                    .font(.headline)
                    .padding(.horizontal)

                List {
                    Section("连接") {
                        HStack(spacing: 16) {
                            Image(systemName: "wifi")
                                .frame(width: 29)
                            Text("Wi-Fi")
                            Spacer()
                            Text("已连接")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .frame(height: 100)
            }

            // 示例 2: 带 Toggle 的 Section
            VStack(alignment: .leading, spacing: 8) {
                Text("Toggle Section")
                    .font(.headline)
                    .padding(.horizontal)

                List {
                    Section("设置") {
                        HStack(spacing: 16) {
                            Image(systemName: "airplane")
                                .frame(width: 29)
                            Text("飞行模式")
                            Spacer()
                            Toggle("", isOn: .constant(false))
                                .labelsHidden()
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .frame(height: 100)
            }

            // 示例 3: 带 NavigationLink 的 Section
            VStack(alignment: .leading, spacing: 8) {
                Text("NavigationLink Section")
                    .font(.headline)
                    .padding(.horizontal)

                List {
                    Section("通用") {
                        NavigationLink("关于本机") {
                            Text("详情")
                        }
                        NavigationLink("软件更新") {
                            Text("详情")
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .frame(height: 120)
            }
        }
        .padding()
    }
    .navigationTitle("组件示例")
}
#endif
#endif
