import CisumUIComponents
import SwiftUI

/// 重置 关于视图 —— Landing 落地页。
struct SystemPluginAboutView: View {
    @LumiTheme private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            LandingHero(
                icon: "arrow.counterclockwise",
                accent: theme.primary,
                tagline: "重置应用状态或数据，恢复初始状态。",
                chips: ["重置"],
                metrics: [
                    .init(value: "1.0.0", label: "版本"),
                    .init(value: "插件", label: "类型")
                ]
            )
            .landingAppear()

            LandingSection(title: "核心能力", icon: "sparkles") {
                LandingFeatureGrid(items: [
                .init(icon: "arrow.counterclockwise", tint: theme.primary, title: "重置", description: "将应用恢复至初始状态。"),
                .init(icon: "exclamationmark.triangle", tint: theme.info, title: "风险提示", description: "重置前给出风险提示。"),
                ], minColumnWidth: 180)
            }
            .landingAppear(delay: 0.05)
        }
    }
}
