import CisumUIComponents
import SwiftUI

/// 播放控制 说明书 —— 章节式文档。
struct AudioControlPluginManualView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            ManualHeader(title: String(localized: "Playback Control", bundle: .module), subtitle: "User Manual")

            ManualSectionHeader(number: 1, title: String(localized: "Overview", bundle: .module))
            Text("Control play, pause, previous, and next for the current music")
                .font(.appBody)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)

            ManualSectionHeader(number: 2, title: String(localized: "Core Capabilities", bundle: .module))
            ManualBulletList(items: [
                .init(String(localized: "Play / Pause: one-click toggle of the playback state.", bundle: .module)),
                .init(String(localized: "Previous: switches to the previous track.", bundle: .module)),
                .init(String(localized: "Next: switches to the next track.", bundle: .module)),
            ])

            ManualSectionHeader(number: 3, title: String(localized: "Basic Operations", bundle: .module))
            ManualStepList(items: [
                .init(String(localized: "Click the play / pause button in the player area.", bundle: .module)),
                .init(String(localized: "Click Previous / Next to switch tracks.", bundle: .module)),
            ])

            ManualSectionHeader(number: 4, title: String(localized: "Notes", bundle: .module))
            ManualBulletList(items: [
                .init(String(localized: "Requires music that is currently playing.", bundle: .module)),
            ])
        }
        .frame(maxWidth: 620, alignment: .leading)
    }
}
