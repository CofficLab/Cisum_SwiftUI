import CisumUIComponents
import SwiftUI

/// 下载管理 关于视图 —— Landing 落地页。
struct AudioDownloadPluginAboutView: View {
    @LumiTheme private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            LandingHero(
                icon: "arrow.down.circle",
                accent: theme.primary,
                tagline: "下载与管理音乐文件，支持离线播放。",
                chips: ["下载管理"],
                metrics: [
                    .init(value: "1.0.0", label: "版本"),
                    .init(value: "插件", label: "类型")
                ]
            )
            .landingAppear()

            LandingSection(title: "核心能力", icon: "sparkles") {
                LandingFeatureGrid(items: [
                .init(icon: "arrow.down.circle", tint: theme.primary, title: "下载", description: "将音乐下载到本地。"),
                .init(icon: "externaldrive.badge.checkmark", tint: theme.info, title: "离线", description: "下载后无需网络即可播放。"),
                .init(icon: "list.bullet", tint: theme.success, title: "队列", description: "查看与管理下载任务。"),
                ], minColumnWidth: 180)
            }
            .landingAppear(delay: 0.05)
        }
    }
}
