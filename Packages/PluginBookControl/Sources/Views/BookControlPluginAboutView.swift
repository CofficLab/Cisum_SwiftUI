import CisumUIComponents
import SwiftUI

/// 有声书控制 关于视图 —— Landing 落地页。
struct BookControlPluginAboutView: View {
    @LumiTheme private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            LandingHero(
                icon: "playpause",
                accent: theme.primary,
                tagline: "控制当前有声书的播放、暂停与上下章节。",
                chips: ["有声书控制"],
                metrics: [
                    .init(value: "1.0.0", label: "版本"),
                    .init(value: "插件", label: "类型")
                ]
            )
            .landingAppear()

            LandingSection(title: "核心能力", icon: "sparkles") {
                LandingFeatureGrid(items: [
                .init(icon: "playpause", tint: theme.primary, title: "播放 / 暂停", description: "一键切换播放状态。"),
                .init(icon: "backward.end", tint: theme.info, title: "上一章", description: "切换到上一章节。"),
                .init(icon: "forward.end", tint: theme.success, title: "下一章", description: "切换到下一章节。"),
                ], minColumnWidth: 180)
            }
            .landingAppear(delay: 0.05)
        }
    }
}
