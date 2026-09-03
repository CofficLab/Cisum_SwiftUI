import CisumUIComponents
import SwiftUI

/// 后台任务 关于视图 —— Landing 落地页。
struct AudioJobPluginAboutView: View {
    @LumiTheme private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            LandingHero(
                icon: "gearshape.2",
                accent: theme.primary,
                tagline: "为音频文件提供后台处理任务能力。",
                chips: ["后台任务"],
                metrics: [
                    .init(value: "1.0.0", label: "版本"),
                    .init(value: "插件", label: "类型")
                ]
            )
            .landingAppear()

            LandingSection(title: "核心能力", icon: "sparkles") {
                LandingFeatureGrid(items: [
                .init(icon: "gearshape.2", tint: theme.primary, title: "后台处理", description: "在后台执行音频相关的任务。"),
                .init(icon: "clock", tint: theme.info, title: "任务调度", description: "按队列调度与执行。"),
                .init(icon: "checkmark.circle", tint: theme.success, title: "完成通知", description: "任务完成后给出反馈。"),
                ], minColumnWidth: 180)
            }
            .landingAppear(delay: 0.05)
        }
    }
}
