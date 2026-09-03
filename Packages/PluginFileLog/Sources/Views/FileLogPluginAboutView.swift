import CisumUIComponents
import SwiftUI

/// 文件日志 关于视图 —— Landing 落地页。
struct FileLogPluginAboutView: View {
    @LumiTheme private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            LandingHero(
                icon: "doc.text",
                accent: theme.primary,
                tagline: "记录应用运行与文件操作日志，便于排查问题。",
                chips: ["文件日志"],
                metrics: [
                    .init(value: "1.0.0", label: "版本"),
                    .init(value: "插件", label: "类型")
                ]
            )
            .landingAppear()

            LandingSection(title: "核心能力", icon: "sparkles") {
                LandingFeatureGrid(items: [
                .init(icon: "doc.text", tint: theme.primary, title: "日志记录", description: "记录关键运行事件。"),
                .init(icon: "magnifyingglass", tint: theme.info, title: "检索", description: "按关键字检索日志。"),
                .init(icon: "trash", tint: theme.success, title: "清理", description: "清理历史日志。"),
                ], minColumnWidth: 180)
            }
            .landingAppear(delay: 0.05)
        }
    }
}
