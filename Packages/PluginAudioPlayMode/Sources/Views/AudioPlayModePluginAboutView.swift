import CisumUIComponents
import SwiftUI

/// 播放模式 关于视图 —— Landing 落地页。
struct AudioPlayModePluginAboutView: View {
    @LumiTheme private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            LandingHero(
                icon: "repeat",
                accent: theme.primary,
                tagline: "切换单曲循环、列表循环、随机等播放模式。",
                chips: ["播放模式"],
                metrics: [
                    .init(value: "1.0.0", label: "版本"),
                    .init(value: "插件", label: "类型")
                ]
            )
            .landingAppear()

            LandingSection(title: "核心能力", icon: "sparkles") {
                LandingFeatureGrid(items: [
                .init(icon: "repeat", tint: theme.primary, title: "循环", description: "单曲 / 列表循环。"),
                .init(icon: "shuffle", tint: theme.info, title: "随机", description: "随机播放全部曲目。"),
                .init(icon: "arrow.triangle.2.circlepath", tint: theme.success, title: "顺序", description: "按列表顺序播放。"),
                ], minColumnWidth: 180)
            }
            .landingAppear(delay: 0.05)
        }
    }
}
