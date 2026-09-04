import CisumUIComponents
import SwiftUI

/// 播放引擎 关于视图 —— Landing 落地页。
struct PluginPlayBackAboutView: View {
    @LumiTheme private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            LandingHero(
                icon: "play.circle",
                accent: theme.primary,
                tagline: "统一播放引擎与播放状态管理。",
                chips: ["播放引擎"],
                metrics: [
                    .init(value: "1.0.0", label: "版本"),
                    .init(value: "插件", label: "类型")
                ]
            )
            .landingAppear()

            LandingSection(title: "核心能力", icon: "sparkles") {
                LandingFeatureGrid(items: [
                .init(icon: "play.circle", tint: theme.primary, title: "播放引擎", description: "驱动音频解码与播放控制。"),
                .init(icon: "arrow.clockwise", tint: theme.info, title: "启动恢复", description: "重启后恢复上次播放的文件。"),
                .init(icon: "internaldrive", tint: theme.success, title: "状态持久化", description: "记录当前播放文件到磁盘。"),
                ], minColumnWidth: 180)
            }
            .landingAppear(delay: 0.05)
        }
    }
}
