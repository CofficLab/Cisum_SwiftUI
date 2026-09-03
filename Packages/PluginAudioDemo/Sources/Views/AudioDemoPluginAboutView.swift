import CisumUIComponents
import SwiftUI

/// 音乐演示 关于视图 —— Landing 落地页。
struct AudioDemoPluginAboutView: View {
    @LumiTheme private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            LandingHero(
                icon: "wand.and.stars",
                accent: theme.primary,
                tagline: "提供音乐播放功能的演示数据与体验。",
                chips: ["音乐演示"],
                metrics: [
                    .init(value: "1.0.0", label: "版本"),
                    .init(value: "插件", label: "类型")
                ]
            )
            .landingAppear()

            LandingSection(title: "核心能力", icon: "sparkles") {
                LandingFeatureGrid(items: [
                .init(icon: "wand.and.stars", tint: theme.primary, title: "演示数据", description: "一键生成演示音乐内容。"),
                .init(icon: "play.rectangle", tint: theme.info, title: "快速体验", description: "无需真实文件即可体验播放。"),
                ], minColumnWidth: 180)
            }
            .landingAppear(delay: 0.05)
        }
    }
}
