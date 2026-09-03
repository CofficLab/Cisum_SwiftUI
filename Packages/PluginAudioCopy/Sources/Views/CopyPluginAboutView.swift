import CisumUIComponents
import SwiftUI

/// 复制 关于视图 —— Landing 落地页。
struct CopyPluginAboutView: View {
    @LumiTheme private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            LandingHero(
                icon: "doc.on.doc",
                accent: theme.primary,
                tagline: "一键复制当前音乐文件到剪贴板。",
                chips: ["复制"],
                metrics: [
                    .init(value: "1.0.0", label: "版本"),
                    .init(value: "插件", label: "类型")
                ]
            )
            .landingAppear()

            LandingSection(title: "核心能力", icon: "sparkles") {
                LandingFeatureGrid(items: [
                .init(icon: "doc.on.doc", tint: theme.primary, title: "复制文件", description: "将当前播放音乐复制到剪贴板。"),
                .init(icon: "checkmark.circle", tint: theme.info, title: "完成提示", description: "复制完成后给出状态反馈。"),
                ], minColumnWidth: 180)
            }
            .landingAppear(delay: 0.05)
        }
    }
}
