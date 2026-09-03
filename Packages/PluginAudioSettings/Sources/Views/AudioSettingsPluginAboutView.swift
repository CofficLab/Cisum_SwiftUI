import CisumUIComponents
import SwiftUI

/// 音乐设置 关于视图 —— Landing 落地页。
struct AudioSettingsPluginAboutView: View {
    @LumiTheme private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            LandingHero(
                icon: "gearshape",
                accent: theme.primary,
                tagline: "提供音乐相关的设置项。",
                chips: ["音乐设置"],
                metrics: [
                    .init(value: "1.0.0", label: "版本"),
                    .init(value: "插件", label: "类型")
                ]
            )
            .landingAppear()

            LandingSection(title: "核心能力", icon: "sparkles") {
                LandingFeatureGrid(items: [
                .init(icon: "gearshape", tint: theme.primary, title: "播放设置", description: "配置播放相关的偏好。"),
                .init(icon: "slider.horizontal.3", tint: theme.info, title: "偏好项", description: "集中管理音乐设置。"),
                ], minColumnWidth: 180)
            }
            .landingAppear(delay: 0.05)
        }
    }
}
