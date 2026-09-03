import CisumUIComponents
import SwiftUI

/// 播放进度 关于视图 —— Landing 落地页。
struct AudioProgressPluginAboutView: View {
    @LumiTheme private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            LandingHero(
                icon: "waveform",
                accent: theme.primary,
                tagline: "展示与拖动音乐播放进度。",
                chips: ["播放进度"],
                metrics: [
                    .init(value: "1.0.0", label: "版本"),
                    .init(value: "插件", label: "类型")
                ]
            )
            .landingAppear()

            LandingSection(title: "核心能力", icon: "sparkles") {
                LandingFeatureGrid(items: [
                .init(icon: "waveform", tint: theme.primary, title: "进度条", description: "展示当前播放位置。"),
                .init(icon: "gauge.with.dots.needle.67percent", tint: theme.info, title: "拖动定位", description: "拖动跳转到任意位置。"),
                ], minColumnWidth: 180)
            }
            .landingAppear(delay: 0.05)
        }
    }
}
