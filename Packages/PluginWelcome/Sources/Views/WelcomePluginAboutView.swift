import CisumUIComponents
import SwiftUI

/// 欢迎页 关于视图 —— Landing 落地页。
struct WelcomePluginAboutView: View {
    @LumiTheme private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            LandingHero(
                icon: "hand.wave",
                accent: theme.primary,
                tagline: "首次启动时展示欢迎引导，帮助快速上手。",
                chips: ["欢迎页"],
                metrics: [
                    .init(value: "1.0.0", label: "版本"),
                    .init(value: "插件", label: "类型")
                ]
            )
            .landingAppear()

            LandingSection(title: "核心能力", icon: "sparkles") {
                LandingFeatureGrid(items: [
                .init(icon: "hand.wave", tint: theme.primary, title: "欢迎引导", description: "首次启动展示欢迎内容。"),
                .init(icon: "checkmark.circle", tint: theme.info, title: "快速上手", description: "引导配置存储与基本操作。"),
                ], minColumnWidth: 180)
            }
            .landingAppear(delay: 0.05)
        }
    }
}
