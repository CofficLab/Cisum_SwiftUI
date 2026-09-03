import CisumUIComponents
import SwiftUI

/// 有声书设置 关于视图 —— Landing 落地页。
struct BookSettingsPluginAboutView: View {
    @LumiTheme private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            LandingHero(
                icon: "gearshape",
                accent: theme.primary,
                tagline: "提供有声书相关的设置项。",
                chips: ["有声书设置"],
                metrics: [
                    .init(value: "1.0.0", label: "版本"),
                    .init(value: "插件", label: "类型")
                ]
            )
            .landingAppear()

            LandingSection(title: "核心能力", icon: "sparkles") {
                LandingFeatureGrid(items: [
                .init(icon: "gearshape", tint: theme.primary, title: "播放设置", description: "配置有声书播放相关的偏好。"),
                .init(icon: "slider.horizontal.3", tint: theme.info, title: "偏好项", description: "集中管理有声书设置。"),
                ], minColumnWidth: 180)
            }
            .landingAppear(delay: 0.05)
        }
    }
}
