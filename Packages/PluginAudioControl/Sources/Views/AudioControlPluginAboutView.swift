import CisumUIComponents
import SwiftUI

/// 播放控制 关于视图 —— Landing 落地页。
struct AudioControlPluginAboutView: View {
    @LumiTheme private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            LandingHero(
                icon: "playpause",
                accent: theme.primary,
                tagline: "控制当前音乐的播放、暂停、上一首与下一首。",
                chips: ["播放控制"],
                metrics: [
                    .init(value: "1.0.0", label: "版本"),
                    .init(value: "插件", label: "类型")
                ]
            )
            .landingAppear()

            LandingSection(title: "核心能力", icon: "sparkles") {
                LandingFeatureGrid(items: [
                .init(icon: "playpause", tint: theme.primary, title: "播放 / 暂停", description: "一键切换播放状态。"),
                .init(icon: "backward.end", tint: theme.info, title: "上一首", description: "切换到上一曲目。"),
                .init(icon: "forward.end", tint: theme.success, title: "下一首", description: "切换到下一曲目。"),
                ], minColumnWidth: 180)
            }
            .landingAppear(delay: 0.05)
        }
    }
}
