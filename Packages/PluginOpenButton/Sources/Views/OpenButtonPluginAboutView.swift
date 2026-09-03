import CisumUIComponents
import SwiftUI

/// 打开当前 关于视图 —— Landing 落地页。
struct OpenButtonPluginAboutView: View {
    @LumiTheme private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            LandingHero(
                icon: "folder",
                accent: theme.primary,
                tagline: "在工具栏提供「打开当前」入口，快速定位当前播放文件。",
                chips: ["打开当前"],
                metrics: [
                    .init(value: "1.0.0", label: "版本"),
                    .init(value: "插件", label: "类型")
                ]
            )
            .landingAppear()

            LandingSection(title: "核心能力", icon: "sparkles") {
                LandingFeatureGrid(items: [
                .init(icon: "folder", tint: theme.primary, title: "打开文件", description: "在文件管理器中显示当前文件。"),
                .init(icon: "arrow.up.forward.square", tint: theme.info, title: "快速跳转", description: "一键定位当前播放内容。"),
                ], minColumnWidth: 180)
            }
            .landingAppear(delay: 0.05)
        }
    }
}
