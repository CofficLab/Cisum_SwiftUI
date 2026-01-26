import MagicKit
import MagicPlayMan
import SwiftUI

/// 播放模式按钮
struct PlayModeButton: View {
    @EnvironmentObject var man: PlayMan
    @Environment(\.demoMode) var isDemoMode

    var body: some View {
        Group {
            switch man.playMode {
            case .sequence:
                modeIcon(systemName: .iconMusicNoteList)
            case .repeatAll:
                modeIcon(systemName: .iconRepeatAll)
            case .loop:
                modeIcon(systemName: .iconRepeat1)
            case .shuffle:
                modeIcon(systemName: .iconShuffle)
            }
        }
        .hoverScale(110)
        .shadowSm()
    }

    private func modeIcon(systemName: String) -> some View {
        Image(systemName: systemName)
            .frame(width: 32, height: 32)
            .inCard()
            .roundedFull()
            .inButtonWithAction {
                man.togglePlayMode()
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
