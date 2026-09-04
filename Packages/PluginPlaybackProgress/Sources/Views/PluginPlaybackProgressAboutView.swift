import CisumUIComponents
import SwiftUI

/// 播放进度 关于视图 —— Landing 落地页。
struct PlaybackProgressPluginAboutView: View {
    @LumiTheme private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            LandingHero(
                icon: "waveform",
                accent: theme.primary,
                tagline: "播放器控制区进度条。",
                chips: ["播放控制"],
                metrics: [
                    .init(value: "1.0.0", label: "版本"),
                    .init(value: "插件", label: "类型")
                ]
            )
            .landingAppear()

            LandingSection(title: "核心能力", icon: "sparkles") {
                LandingFeatureGrid(items: [
                    .init(icon: "gauge.with.dots.needle.50percent", tint: theme.primary, title: "进度显示", description: "实时展示当前播放位置。"),
                    .init(icon: "hand.draw", tint: theme.info, title: "拖动控制", description: "拖动进度条调整播放位置。"),
                ], minColumnWidth: 180)
            }
            .landingAppear(delay: 0.05)
        }
    }
}
