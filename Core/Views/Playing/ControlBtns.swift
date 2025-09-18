import MagicCore
import OSLog
import SwiftUI

struct ControlBtns: View, SuperLog {
    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var message: StateProvider
    @EnvironmentObject var man: PlayManController

    nonisolated static let emoji = "🎵"
    static let verbose = false

    init() {
        if Self.verbose {
            os_log("\(Self.i)")
        }
    }

    var body: some View {
        if Self.verbose {
            os_log("\(self.t)开始渲染")
        }
        return HStack {
            Spacer(minLength: 50)
            BtnToggleDB()
            man.playMan.makePreviousButtonView(size: .auto)
            man.playMan.makePlayPauseButtonView(size: .auto)
            man.playMan.makeNextButtonView(size: .auto)
            man.playMan.makePlayModeButtonView(size: .auto)
            Spacer(minLength: 50)
        }
        .padding(.bottom, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Preview

#if os(macOS)
#Preview("App - Large") {
    AppPreview()
        .frame(width: 600, height: 1000)
}

#Preview("App - Small") {
    AppPreview()
        .frame(width: 500, height: 800)
}
#endif

#if os(iOS)
#Preview("iPhone") {
    AppPreview()
}
#endif


