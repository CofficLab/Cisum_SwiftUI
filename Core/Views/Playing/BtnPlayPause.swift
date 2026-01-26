import MagicKit
import MagicPlayMan
import SwiftUI

/// 播放/暂停按钮
struct PlayPauseButton: View {
    @EnvironmentObject var man: PlayMan
    @Environment(\.demoMode) var isDemoMode

    var body: some View {
        Group {
            if man.state == .playing {
                pauseButton
            } else {
                playButton
            }
        }
        .hoverScale(110)
        .shadowSm()
    }

    private var playButton: some View {
        Image.playFill
            .frame(width: 32, height: 32)
            .foregroundColor(.blue)
            .inCard()
            .roundedFull()
            .inButtonWithAction {
                man.playCurrent(reason: "PlayPauseButton")
            }
    }

    private var pauseButton: some View {
        Image.pauseFill
            .frame(width: 32, height: 32)
            .foregroundColor(.blue)
            .inCard()
            .roundedFull()
            .inButtonWithAction {
                man.pause(reason: "PlayPauseButton")
            }
    }
}

// MARK: - Preview

#if os(macOS)
    #Preview("App - Large") {
        ContentView()
            .inRootView()
            .frame(width: 600, height: 1000)
    }

    #Preview("App - Small") {
        ContentView()
            .inRootView()
            .frame(width: 500, height: 800)
    }

    #Preview("App Store Hero") {
        AppStoreHero()
            .inMagicContainer(.macBook13, scale: 1)
    }
#endif

#if os(iOS)
    #Preview("iPhone") {
        ContentView()
            .inRootView()
    }
#endif
