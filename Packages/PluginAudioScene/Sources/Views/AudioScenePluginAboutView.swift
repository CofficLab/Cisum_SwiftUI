import CisumUIComponents
import SwiftUI

/// 音乐场景 关于视图 —— Landing 落地页。
struct AudioScenePluginAboutView: View {
    @LumiTheme private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            LandingHero(
                icon: "music.note.list",
                accent: theme.primary,
                tagline: "提供「音乐库」场景，是音乐功能的主入口。",
                chips: ["音乐场景"],
                metrics: [
                    .init(value: "1.0.0", label: "版本"),
                    .init(value: "插件", label: "类型")
                ]
            )
            .landingAppear()

            LandingSection(title: "核心能力", icon: "sparkles") {
                LandingFeatureGrid(items: [
                .init(icon: "music.note.list", tint: theme.primary, title: "音乐库", description: "音乐场景的主界面。"),
                .init(icon: "rectangle.3.group", tint: theme.info, title: "场景切换", description: "与其他场景（有声书）互斥切换。"),
                ], minColumnWidth: 180)
            }
            .landingAppear(delay: 0.05)
        }
    }
}
