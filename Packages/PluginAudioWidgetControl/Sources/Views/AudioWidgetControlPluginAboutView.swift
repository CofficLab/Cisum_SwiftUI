import CisumUIComponents
import SwiftUI

/// 小组件控制 关于视图 —— Landing 落地页。
struct AudioWidgetControlPluginAboutView: View {
    @LumiTheme private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            LandingHero(
                icon: "rectangle.grid.2x2",
                accent: theme.primary,
                tagline: "通过桌面小组件控制音乐播放。",
                chips: ["小组件控制"],
                metrics: [
                    .init(value: "1.0.0", label: "版本"),
                    .init(value: "插件", label: "类型")
                ]
            )
            .landingAppear()

            LandingSection(title: "核心能力", icon: "sparkles") {
                LandingFeatureGrid(items: [
                .init(icon: "rectangle.grid.2x2", tint: theme.primary, title: "小组件", description: "在桌面小组件中展示播放状态。"),
                .init(icon: "playpause.fill", tint: theme.info, title: "快捷控制", description: "从小组件直接播放 / 暂停。"),
                ], minColumnWidth: 180)
            }
            .landingAppear(delay: 0.05)
        }
    }
}
