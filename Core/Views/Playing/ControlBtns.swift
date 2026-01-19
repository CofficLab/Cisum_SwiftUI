import MagicKit
import OSLog
import SwiftUI

struct ControlBtns: View, SuperLog {
    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var message: StateProvider
    @EnvironmentObject var man: PlayMan

    nonisolated static let emoji = "🎵"
    static let verbose = false

    var body: some View {
        HStack {
            Spacer(minLength: 50)
            BtnToggleDB()
            man.makePreviousButtonView(size: .auto)
            man.makePlayPauseButtonView(size: .auto)
            man.makeNextButtonView(size: .auto)
            man.makePlayModeButtonView(size: .auto)
            Spacer(minLength: 50)
        }
        .padding(.bottom, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
#endif

#if os(iOS)
    #Preview("iPhone") {
        ContentView()
            .inRootView()
    }
#endif
