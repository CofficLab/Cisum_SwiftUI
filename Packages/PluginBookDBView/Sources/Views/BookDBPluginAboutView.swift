import CisumUIComponents
import SwiftUI

/// 有声书数据库 关于视图 —— Landing 落地页。
struct BookDBPluginAboutView: View {
    @LumiTheme private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            LandingHero(
                icon: "externaldrive",
                accent: theme.primary,
                tagline: "以数据库视图浏览与整理有声书文件。",
                chips: ["有声书数据库"],
                metrics: [
                    .init(value: "1.0.0", label: "版本"),
                    .init(value: "插件", label: "类型")
                ]
            )
            .landingAppear()

            LandingSection(title: "核心能力", icon: "sparkles") {
                LandingFeatureGrid(items: [
                .init(icon: "externaldrive", tint: theme.primary, title: "数据库", description: "集中管理有声书文件的数据库记录。"),
                .init(icon: "arrow.up.arrow.down", tint: theme.info, title: "排序", description: "按多种维度排序浏览。"),
                .init(icon: "trash", tint: theme.success, title: "清理", description: "清理无效或重复的记录。"),
                ], minColumnWidth: 180)
            }
            .landingAppear(delay: 0.05)
        }
    }
}
