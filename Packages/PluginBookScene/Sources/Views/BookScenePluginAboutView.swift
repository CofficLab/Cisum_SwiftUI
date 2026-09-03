import CisumUIComponents
import SwiftUI

/// 有声书场景 关于视图 —— Landing 落地页。
struct BookScenePluginAboutView: View {
    @LumiTheme private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            LandingHero(
                icon: "book.closed",
                accent: theme.primary,
                tagline: "提供「有声书」场景，是有声书功能的主入口。",
                chips: ["有声书场景"],
                metrics: [
                    .init(value: "1.0.0", label: "版本"),
                    .init(value: "插件", label: "类型")
                ]
            )
            .landingAppear()

            LandingSection(title: "核心能力", icon: "sparkles") {
                LandingFeatureGrid(items: [
                .init(icon: "book.closed", tint: theme.primary, title: "有声书库", description: "有声书场景的主界面。"),
                .init(icon: "rectangle.3.group", tint: theme.info, title: "场景切换", description: "与其他场景（音乐库）互斥切换。"),
                ], minColumnWidth: 180)
            }
            .landingAppear(delay: 0.05)
        }
    }
}
