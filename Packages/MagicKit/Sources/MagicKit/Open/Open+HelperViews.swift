import SwiftUI

// MARK: - Helper Views

#if os(macOS)
/// 真实应用图标视图
/// 处理 NSImage 到 SwiftUI Image 的转换
struct RealIconButtonView: View {
    let appType: OpenAppType
    let url: URL

    var body: some View {
        let iconValue = appType.realIcon(for: url, useRealIcon: true)

        if let nsImage = iconValue as? NSImage {
            // 使用真实应用图标
            // 注意：需要 .resizable() 才能让 NSImage 适应 frame 的大小
            Image(nsImage: nsImage)
                .resizable()
        } else if let iconName = iconValue as? String {
            // 回退到系统图标
            // SF Symbols 不需要 .resizable()，它们会自动缩放
            Image(systemName: iconName)
        } else {
            // 默认图标
            Image(systemName: "app")
        }
    }
}
#else
/// iOS 版本（不支持真实图标）
struct RealIconButtonView: View {
    let appType: OpenAppType
    let url: URL

    var body: some View {
        Image(systemName: appType.icon(for: url))
    }
}
#endif

#if macOS
// MARK: - Previews

#Preview("Real Icon Button View") {
    VStack(spacing: 30) {
        Text("RealIconButtonView 测试")
            .font(.title)
            .padding()

        HStack(spacing: 40) {
            // Safari - 系统图标
            VStack(spacing: 8) {
                RealIconButtonView(
                    appType: .safari,
                    url: URL.sample_web_mp3_kennedy
                )
                .frame(width: 48, height: 48)
                Text("Safari (系统)")
                    .font(.caption)
            }

            // Xcode - 真实图标（如果已安装）
            VStack(spacing: 8) {
                RealIconButtonView(
                    appType: .xcode,
                    url: URL.sample_temp_txt
                )
                .frame(width: 48, height: 48)
                Text("Xcode")
                    .font(.caption)
                if OpenAppType.xcode.isInstalled {
                    Text("已安装")
                        .font(.caption2)
                        .foregroundColor(.green)
                } else {
                    Text("未安装")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            // VS Code - 真实图标（如果已安装）
            VStack(spacing: 8) {
                RealIconButtonView(
                    appType: .vscode,
                    url: URL.sample_temp_txt
                )
                .frame(width: 48, height: 48)
                Text("VS Code")
                    .font(.caption)
                if OpenAppType.vscode.isInstalled {
                    Text("已安装")
                        .font(.caption2)
                        .foregroundColor(.green)
                } else {
                    Text("未安装")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()

        Divider()
            .padding()

        // 更多示例
        ScrollView {
            VStack(spacing: 16) {
                Text("所有应用类型")
                    .font(.headline)

                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 80))
                ], spacing: 16) {
                    ForEach([
                        OpenAppType.xcode,
                        OpenAppType.vscode,
                        OpenAppType.cursor,
                        OpenAppType.chrome,
                        OpenAppType.safari,
                        OpenAppType.terminal,
                        OpenAppType.preview,
                        OpenAppType.textEdit
                    ], id: \.self) { appType in
                        VStack(spacing: 8) {
                            RealIconButtonView(
                                appType: appType,
                                url: URL.sample_temp_txt
                            )
                            .frame(width: 40, height: 40)

                            Text(appType.displayName)
                                .font(.caption2)
                                .lineLimit(2)
                                .multilineTextAlignment(.center)

                            if appType.isInstalled {
                                Circle()
                                    .fill(.green)
                                    .frame(width: 6, height: 6)
                            }
                        }
                    }
                }
                .padding()
            }
        }
    }
    .frame(width: 500, height: 600)
}
#endif

