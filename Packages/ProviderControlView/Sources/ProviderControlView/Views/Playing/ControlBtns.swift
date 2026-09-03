import CisumUIComponents
import MagicPlayMan
import SwiftUI

/// 播放操作按钮。
struct ControlBtns: View {
    @EnvironmentObject private var man: MagicPlayMan
    let toggleDBView: @MainActor () -> Void

    var body: some View {
        HStack(spacing: 4) {
            Spacer(minLength: 1)

            AppCircularIconButton(
                systemImage: "ellipsis",
                accessibilityLabel: "More",
                action: toggleDBView
            )
            AppCircularIconButton(
                systemImage: "backward.end.fill",
                accessibilityLabel: "Previous",
                action: man.previous
            )
            AppCircularIconButton(
                systemImage: man.isPlaying ? "pause.fill" : "play.fill",
                accessibilityLabel: man.isPlaying ? "Pause" : "Play",
                isActive: man.isPlaying,
                action: { man.toggle(reason: "ControlBtns") }
            )
            AppCircularIconButton(
                systemImage: "forward.end.fill",
                accessibilityLabel: "Next",
                action: man.next
            )
            AppCircularIconButton(
                systemImage: man.playMode.iconName,
                accessibilityLabel: "Playback mode",
                isActive: man.playMode != .sequence,
                action: man.togglePlayMode
            )

            Spacer(minLength: 1)
        }
        .buttonStyle(.plain)
        .padding(.bottom, 20)
    }
}
