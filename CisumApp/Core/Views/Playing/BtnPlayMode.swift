import CisumUI
import MagicPlayMan
import SwiftUI

/// 播放模式按钮
struct PlayModeButton: View {
    @EnvironmentObject var man: PlayMan
    @Environment(\.demoMode) var isDemoMode
    @LumiTheme private var appTheme
    @LumiMotionPreferenceReader private var motionPreference

    private let size: CGFloat = 32

    var body: some View {
        Group {
            switch man.playMode {
            case .sequence:
                modeIcon(systemName: .cisumIconMusicNoteList)
            case .repeatAll:
                modeIcon(systemName: .cisumIconRepeatAll)
            case .loop:
                modeIcon(systemName: .cisumIconRepeat1)
            case .shuffle:
                modeIcon(systemName: .cisumIconShuffle)
            }
        }
        .appPlaybackIconTransition(preference: motionPreference)
        .animation(
            LumiMotion.enabled(LumiMotion.playbackControl, preference: motionPreference),
            value: man.playMode
        )
        .shadow(color: appTheme.background.opacity(0.10), radius: 4, y: 1)
    }

    private func modeIcon(systemName: String) -> some View {
        Image(systemName: systemName)
            .font(.system(size: self.size * 0.6))
            .frame(width: size, height: size)
            .foregroundStyle(appTheme.textSecondary)
            .cisumCard(.ultraThinMaterial)
            .cisumRoundedFull()
            #if os(iOS)
            .contentTransition(.symbolEffect(.replace))
            #endif
            .cisumPlaybackControl {
                man.togglePlayMode()
            }
    }
}

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}
