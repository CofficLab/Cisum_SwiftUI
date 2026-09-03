import CisumUIComponents
import SwiftUI

/// 有声书库 关于视图 —— Landing 落地页。
struct BookPluginAboutView: View {
    @LumiTheme private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            LandingHero(
                icon: "book",
                accent: theme.primary,
                tagline: "管理、浏览与播放本地有声书。",
                chips: ["有声书库"],
                metrics: [
                    .init(value: "1.0.0", label: "版本"),
                    .init(value: "插件", label: "类型")
                ]
            )
            .landingAppear()

            LandingSection(title: "核心能力", icon: "sparkles") {
                LandingFeatureGrid(items: [
                .init(icon: "book", tint: theme.primary, title: "有声书库", description: "管理本地有声书文件。"),
                .init(icon: "magnifyingglass", tint: theme.info, title: "搜索", description: "按名称快速定位有声书。"),
                .init(icon: "play.circle", tint: theme.success, title: "播放", description: "从书库发起播放。"),
                ], minColumnWidth: 180)
            }
            .landingAppear(delay: 0.05)
        }
    }
}
