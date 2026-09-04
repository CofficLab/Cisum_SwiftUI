import CisumUIComponents
import SwiftUI

/// 播放封面 关于视图 —— Landing 落地页。
struct PlaybackHeroPluginAboutView: View {
    @LumiTheme private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            LandingHero(
                icon: "photo",
                accent: theme.primary,
                tagline: "播放器控制区封面与标题。",
                chips: ["播放控制"],
                metrics: [
                    .init(value: "1.0.0", label: "版本"),
                    .init(value: "插件", label: "类型")
                ]
            )
            .landingAppear()

            LandingSection(title: "核心能力", icon: "sparkles") {
                LandingFeatureGrid(items: [
                    .init(icon: "music.note", tint: theme.primary, title: "封面展示", description: "音频显示封面，视频显示画面。"),
                    .init(icon: "textformat", tint: theme.info, title: "标题显示", description: "展示当前播放曲目标题。"),
                ], minColumnWidth: 180)
            }
            .landingAppear(delay: 0.05)
        }
    }
}
