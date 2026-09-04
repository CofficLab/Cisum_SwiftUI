import CisumUIComponents
import MagicPlayMan
import SwiftUI

/// 播放器底部控制按钮组：更多 / 上一曲 / 播放暂停 / 下一曲 / 播放模式。
struct ControlButtonsView: View {
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
                action: { man.toggle(reason: "ControlButtons") }
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
