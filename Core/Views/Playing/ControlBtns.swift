import MagicKit
import OSLog
import SwiftUI

struct ControlBtns: View, SuperLog {
    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var message: StateProvider

    nonisolated static let emoji = "🎵"
    static let verbose = false

    var body: some View {
        HStack(spacing: 4) {
            Spacer(minLength: 1)

            BtnMore()
            PreviousButton()
            PlayPauseButton()
            NextButton()
            PlayModeButton()

            Spacer(minLength: 1)
        }
        .padding(.bottom, 20)
        .infinite()
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
