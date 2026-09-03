import CisumUIComponents
import SwiftUI

/// 通用设置 关于视图 —— Landing 落地页。
struct SettingGeneralPluginAboutView: View {
    @LumiTheme private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            LandingHero(
                icon: "gearshape",
                accent: theme.primary,
                tagline: "在设置窗口中提供应用信息与说明书等通用设置项。",
                chips: ["通用设置"],
                metrics: [
                    .init(value: "1.0.0", label: "版本"),
                    .init(value: "插件", label: "类型")
                ]
            )
            .landingAppear()

            LandingSection(title: "核心能力", icon: "sparkles") {
                LandingFeatureGrid(items: [
                .init(icon: "app", tint: theme.primary, title: "应用信息", description: "展示名称、版本等基本信息。"),
                .init(icon: "book", tint: theme.info, title: "说明书", description: "浏览各插件的使用说明书。"),
                ], minColumnWidth: 180)
            }
            .landingAppear(delay: 0.05)
        }
    }
}
