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
        #if DEBUG
        .overlay(alignment: .topTrailing) {
            DebugPluginBadge(text: ControlButtonsPlugin.shared.id)
                .padding(8)
        }
        #endif
    }
}

/// 调试徽章 —— 仅 DEBUG 构建下叠加在插件贡献视图右上角，
/// 显示插件自身 id，便于快速识别当前渲染的贡献视图。
#if DEBUG
private struct DebugPluginBadge: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .foregroundStyle(.white)
            .background(.red.opacity(0.85), in: Capsule())
            .overlay(Capsule().strokeBorder(.white.opacity(0.5), lineWidth: 0.5))
            .shadow(color: .black.opacity(0.25), radius: 3, y: 1)
            .allowsHitTesting(false)
    }
}
#endif
