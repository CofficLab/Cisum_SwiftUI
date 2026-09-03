import CisumUIComponents
import SwiftUI

/// 存储管理 关于视图 —— Landing 落地页。
struct StoragePluginAboutView: View {
    @LumiTheme private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            LandingHero(
                icon: "externaldrive",
                accent: theme.primary,
                tagline: "管理应用数据存储位置、迁移与文件浏览。",
                chips: ["存储管理"],
                metrics: [
                    .init(value: "1.0.0", label: "版本"),
                    .init(value: "插件", label: "类型")
                ]
            )
            .landingAppear()

            LandingSection(title: "核心能力", icon: "sparkles") {
                LandingFeatureGrid(items: [
                .init(icon: "externaldrive", tint: theme.primary, title: "存储位置", description: "配置数据存储目录。"),
                .init(icon: "arrow.triangle.2.circlepath", tint: theme.info, title: "迁移", description: "在存储位置之间迁移数据。"),
                .init(icon: "folder", tint: theme.success, title: "文件浏览", description: "浏览应用数据文件。"),
                ], minColumnWidth: 180)
            }
            .landingAppear(delay: 0.05)
        }
    }
}
