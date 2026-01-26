import MagicKit
import MagicPlayMan
import SwiftUI

/// 下一曲按钮
struct NextButton: View {
    @EnvironmentObject var man: PlayMan
    @Environment(\.demoMode) var isDemoMode

    var body: some View {
        Image.forward
            .frame(width: 32, height: 32)
            .inCard()
            .roundedFull()
            .hoverScale(110)
            .inButtonWithAction {
                man.next()
            }
            .shadowSm()
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
