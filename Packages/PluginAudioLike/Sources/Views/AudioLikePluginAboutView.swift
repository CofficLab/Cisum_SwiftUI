import CisumUIComponents
import SwiftUI

/// 音乐喜欢 关于视图 —— Landing 落地页。
struct AudioLikePluginAboutView: View {
    @LumiTheme private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            LandingHero(
                icon: "heart",
                accent: theme.primary,
                tagline: "收藏与标记喜欢的音乐。",
                chips: ["音乐喜欢"],
                metrics: [
                    .init(value: "1.0.0", label: "版本"),
                    .init(value: "插件", label: "类型")
                ]
            )
            .landingAppear()

            LandingSection(title: "核心能力", icon: "sparkles") {
                LandingFeatureGrid(items: [
                .init(icon: "heart", tint: theme.primary, title: "标记喜欢", description: "一键收藏当前音乐。"),
                .init(icon: "heart.fill", tint: theme.info, title: "喜欢列表", description: "集中浏览所有喜欢的音乐。"),
                ], minColumnWidth: 180)
            }
            .landingAppear(delay: 0.05)
        }
    }
}
