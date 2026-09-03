import CisumUIComponents
import SwiftUI

/// 喜欢按钮 关于视图 —— Landing 落地页。
struct LikeButtonPluginAboutView: View {
    @LumiTheme private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            LandingHero(
                icon: "heart",
                accent: theme.primary,
                tagline: "在工具栏提供统一的「喜欢」按钮。",
                chips: ["喜欢按钮"],
                metrics: [
                    .init(value: "1.0.0", label: "版本"),
                    .init(value: "插件", label: "类型")
                ]
            )
            .landingAppear()

            LandingSection(title: "核心能力", icon: "sparkles") {
                LandingFeatureGrid(items: [
                .init(icon: "heart", tint: theme.primary, title: "工具栏按钮", description: "在工具栏快捷标记喜欢。"),
                .init(icon: "heart.fill", tint: theme.info, title: "状态同步", description: "与各媒体喜欢状态联动。"),
                ], minColumnWidth: 180)
            }
            .landingAppear(delay: 0.05)
        }
    }
}
