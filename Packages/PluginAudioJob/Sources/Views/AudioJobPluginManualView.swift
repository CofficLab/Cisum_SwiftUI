import CisumUIComponents
import SwiftUI

/// 后台任务 说明书 —— 章节式文档。
struct AudioJobPluginManualView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            ManualHeader(title: String(localized: "Background Tasks", bundle: .module), subtitle: "User Manual")

            ManualSectionHeader(number: 1, title: String(localized: "Overview", bundle: .module))
            Text("Provides background processing tasks for audio files")
                .font(.appBody)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)

            ManualSectionHeader(number: 2, title: String(localized: "Core Capabilities", bundle: .module))
            ManualBulletList(items: [
                .init(String(localized: "Background Processing: runs audio-related tasks in the background.", bundle: .module)),
                .init(String(localized: "Task Scheduling: schedules and executes by queue.", bundle: .module)),
                .init(String(localized: "Completion Notification: gives feedback when a task finishes.", bundle: .module)),
            ])

            ManualSectionHeader(number: 3, title: String(localized: "Basic Operations", bundle: .module))
            ManualStepList(items: [
                .init(String(localized: "Triggers background audio tasks.", bundle: .module)),
                .init(String(localized: "View execution status in the task queue.", bundle: .module)),
            ])

            ManualSectionHeader(number: 4, title: String(localized: "Notes", bundle: .module))
            ManualBulletList(items: [
                .init(String(localized: "Tasks run asynchronously in the background without affecting foreground playback.", bundle: .module)),
            ])
        }
        .frame(maxWidth: 620, alignment: .leading)
    }
}
