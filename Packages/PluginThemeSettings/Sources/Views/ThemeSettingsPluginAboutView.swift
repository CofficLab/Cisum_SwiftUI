import CisumUIComponents
import SwiftUI

/// 外观设置 关于视图 —— Landing 落地页。
struct ThemeSettingsPluginAboutView: View {
    @LumiTheme private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            LandingHero(
                icon: "paintpalette",
                accent: theme.primary,
                tagline: "在设置窗口中提供主题选择与外观设置。",
                chips: ["外观设置"],
                metrics: [
                    .init(value: "1.0.0", label: "版本"),
                    .init(value: "插件", label: "类型")
                ]
            )
            .landingAppear()

            LandingSection(title: "核心能力", icon: "sparkles") {
                LandingFeatureGrid(items: [
                .init(icon: "paintpalette", tint: theme.primary, title: "主题选择", description: "从全部主题中选择外观。"),
                .init(icon: "moon", tint: theme.info, title: "深色模式", description: "切换深浅色外观。"),
                ], minColumnWidth: 180)
            }
            .landingAppear(delay: 0.05)
        }
    }
}
