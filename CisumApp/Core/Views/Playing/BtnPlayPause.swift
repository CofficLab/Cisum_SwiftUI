import CisumUI
import MagicKit
import MagicPlayMan
import SwiftUI

/// 播放/暂停按钮
struct PlayPauseButton: View {
    @EnvironmentObject var man: PlayMan
    @Environment(\.demoMode) var isDemoMode
    @LumiTheme private var appTheme

    private let size: CGFloat = 32

    var body: some View {
        Group {
            if man.state == .playing {
                pauseButton
            } else {
                playButton
            }
        }
        .hoverScale(105)
        .shadow(color: appTheme.background.opacity(0.12), radius: 5, y: 1)
    }

    private var playButton: some View {
        Image.playFill
            .font(.system(size: self.size * 0.6))
            .foregroundStyle(appTheme.textPrimary)
            .frame(width: size, height: size)
            .inCard(.ultraThinMaterial)
            .roundedFull()
            .inButtonWithAction {
                man.playCurrent(reason: "PlayPauseButton")
            }
    }

    private var pauseButton: some View {
        Image.pauseFill
            .font(.system(size: self.size * 0.6))
            .foregroundStyle(appTheme.textPrimary)
            .frame(width: size, height: size)
            .inCard(.ultraThinMaterial)
            .roundedFull()
            .inButtonWithAction {
                man.pause(reason: "PlayPauseButton")
            }
    }
}

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}
