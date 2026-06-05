import PluginRegistry
import SwiftUI

/// 播放/暂停按钮
struct PlayPauseButton: View {
    @EnvironmentObject var man: PlayMan
    @Environment(\.demoMode) var isDemoMode
    @Environment(\.localization) private var loc
    @LumiTheme private var appTheme
    @LumiMotionPreferenceReader private var motionPreference

    private let size: CGFloat = 36
    private var isPlaying: Bool { man.state == .playing }

    var body: some View {
        Group {
            if isPlaying {
                controlIcon(label: loc.pause, systemName: .cisumIconPauseFill)
                    .cisumPlaybackControl(accessibilityLabel: loc.pause) { man.pause(reason: "PlayPauseButton") }
            } else {
                controlIcon(label: loc.play, systemName: .cisumIconPlayFill)
                    .cisumPlaybackControl(accessibilityLabel: loc.play) { man.playCurrent(reason: "PlayPauseButton") }
            }
        }
        .appPlaybackIconTransition(preference: motionPreference)
        .animation(
            LumiMotion.enabled(LumiMotion.playbackControl, preference: motionPreference),
            value: isPlaying
        )
        .shadow(color: appTheme.background.opacity(0.12), radius: 5, y: 1)
    }

    private func controlIcon(label: String, systemName: String) -> some View {
        Label(label, systemImage: systemName)
            .labelStyle(.iconOnly)
            .font(.system(size: size * 0.58))
            .foregroundStyle(appTheme.textPrimary)
            .frame(width: size, height: size)
            .cisumCard(.ultraThinMaterial)
            .cisumRoundedFull()
            #if os(iOS)
            .contentTransition(.symbolEffect(.replace))
            #endif
    }
}

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}
