import CisumUIComponents
import SwiftUI

/// 音乐库 关于视图 —— Landing 落地页。
struct AudioPluginAboutView: View {
    @LumiTheme private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            LandingHero(
                icon: "music.note.list",
                accent: theme.primary,
                tagline: "管理、浏览与播放本地音乐文件。",
                chips: ["音乐库"],
                metrics: [
                    .init(value: "1.0.0", label: "版本"),
                    .init(value: "插件", label: "类型")
                ]
            )
            .landingAppear()

            LandingSection(title: "核心能力", icon: "sparkles") {
                LandingFeatureGrid(items: [
                .init(icon: "music.note.list", tint: theme.primary, title: "媒体库", description: "管理本地音乐文件并分类浏览。"),
                .init(icon: "magnifyingglass", tint: theme.info, title: "搜索", description: "按名称快速定位音乐。"),
                .init(icon: "play.circle", tint: theme.success, title: "播放", description: "从媒体库发起播放。"),
                ], minColumnWidth: 180)
            }
            .landingAppear(delay: 0.05)
        }
    }
}
