import CisumUIComponents
import SwiftUI

/// 播放控制按钮 关于视图 —— Landing 落地页。
struct PluginControlButtonsAboutView: View {
    @LumiTheme private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            LandingHero(
                icon: "playpause.fill",
                accent: theme.primary,
                tagline: "播放器底部控制按钮组。",
                chips: ["播放控制"],
                metrics: [
                    .init(value: "1.0.0", label: "版本"),
                    .init(value: "插件", label: "类型")
                ]
            )
            .landingAppear()

            LandingSection(title: "核心能力", icon: "sparkles") {
                LandingFeatureGrid(items: [
                    .init(icon: "backward.end.fill", tint: theme.primary, title: "曲目切换", description: "上一曲与下一曲快速切换。"),
                    .init(icon: "playpause.fill", tint: theme.info, title: "播放控制", description: "播放与暂停当前曲目。"),
                    .init(icon: "repeat", tint: theme.success, title: "播放模式", description: "循环切换顺序 / 循环等播放模式。"),
                ], minColumnWidth: 180)
            }
            .landingAppear(delay: 0.05)
        }
    }
}
