import CisumUIComponents
import SwiftUI

/// 场景管理 关于视图 —— Landing 落地页。
struct ScenePluginAboutView: View {
    @LumiTheme private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            LandingHero(
                icon: "rectangle.3.group",
                accent: theme.primary,
                tagline: "管理应用场景（音乐库 / 有声书）的切换与状态。",
                chips: ["场景管理"],
                metrics: [
                    .init(value: "1.0.0", label: "版本"),
                    .init(value: "插件", label: "类型")
                ]
            )
            .landingAppear()

            LandingSection(title: "核心能力", icon: "sparkles") {
                LandingFeatureGrid(items: [
                .init(icon: "rectangle.3.group", tint: theme.primary, title: "场景切换", description: "在音乐库与有声书之间切换。"),
                .init(icon: "arrow.left.arrow.right", tint: theme.info, title: "状态管理", description: "维护当前场景状态。"),
                ], minColumnWidth: 180)
            }
            .landingAppear(delay: 0.05)
        }
    }
}
