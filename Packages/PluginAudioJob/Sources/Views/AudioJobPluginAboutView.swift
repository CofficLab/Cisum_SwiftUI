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
                tagline: String(localized: "Provides background processing tasks for audio files", bundle: .module),
                chips: [String(localized: "Background Tasks", bundle: .module)],
                metrics: [
                    .init(value: "1.0.0", label: String(localized: "Version", bundle: .module)),
                    .init(value: String(localized: "Plugin", bundle: .module), label: String(localized: "Type", bundle: .module))
                ]
            )
            .landingAppear()

            LandingSection(title: String(localized: "Core Capabilities", bundle: .module), icon: "sparkles") {
                LandingFeatureGrid(items: [
                .init(icon: "gearshape.2", tint: theme.primary, title: String(localized: "Background Processing", bundle: .module), description: String(localized: "Runs audio-related tasks in the background.", bundle: .module)),
                .init(icon: "clock", tint: theme.info, title: String(localized: "Task Scheduling", bundle: .module), description: String(localized: "Schedules and executes by queue.", bundle: .module)),
                .init(icon: "checkmark.circle", tint: theme.success, title: String(localized: "Completion Notification", bundle: .module), description: String(localized: "Gives feedback when a task finishes.", bundle: .module)),
                ], minColumnWidth: 180)
            }
            .landingAppear(delay: 0.05)
        }
    }
}
