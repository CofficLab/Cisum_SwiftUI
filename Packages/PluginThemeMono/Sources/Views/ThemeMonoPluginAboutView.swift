import CisumUIComponents
import SwiftUI

/// 单色 关于视图 —— Landing 落地页。
struct ThemeMonoPluginAboutView: View {
    @LumiTheme private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            LandingHero(
                icon: "circle.lefthalf.filled",
                accent: theme.primary,
                tagline: "极简的黑白灰单色主题。",
                chips: ["单色"],
                metrics: [
                    .init(value: "1.0.0", label: "版本"),
                    .init(value: "插件", label: "类型")
                ]
            )
            .landingAppear()

            LandingSection(title: "核心能力", icon: "sparkles") {
                LandingFeatureGrid(items: [
                .init(icon: "paintpalette", tint: theme.primary, title: "主题外观", description: "「单色」主题的整体配色与质感。"),
                .init(icon: "circle.lefthalf.filled", tint: theme.info, title: "明暗适配", description: "适配系统深浅色模式。"),
                .init(icon: "arrow.2.squarepath", tint: theme.success, title: "即时切换", description: "切换后立即应用，无需重启。"),
                ], minColumnWidth: 180)
            }
            .landingAppear(delay: 0.05)
        }
    }
}
