import CisumUIComponents
import SwiftUI

/// 播放器底部控制按钮组：更多 / 上一曲 / 播放暂停 / 下一曲 / 播放模式。
struct ControlButtonsView: View {
    @ObservedObject private var viewModel: ControlButtonsViewModel
    let toggleDBView: @MainActor () -> Void

    init(viewModel: ControlButtonsViewModel, toggleDBView: @escaping @MainActor () -> Void) {
        self.viewModel = viewModel
        self.toggleDBView = toggleDBView
    }

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
                action: viewModel.previous
            )
            AppCircularIconButton(
                systemImage: viewModel.isPlaying ? "pause.fill" : "play.fill",
                accessibilityLabel: viewModel.isPlaying ? "Pause" : "Play",
                isActive: viewModel.isPlaying,
                action: viewModel.toggle
            )
            AppCircularIconButton(
                systemImage: "forward.end.fill",
                accessibilityLabel: "Next",
                action: viewModel.next
            )
            AppCircularIconButton(
                systemImage: viewModel.playMode.iconName,
                accessibilityLabel: "Playback mode",
                isActive: viewModel.playMode != .sequence,
                action: viewModel.togglePlayMode
            )

            Spacer(minLength: 1)
        }
        .buttonStyle(.plain)
        .padding(.bottom, 20)

    }
}
