import MagicKit
import MagicPlayMan
import SwiftUI

/// 上一曲按钮
struct PreviousButton: View {
    @EnvironmentObject var man: PlayMan
    @Environment(\.demoMode) var isDemoMode

    var body: some View {
        Image.backward
            .foregroundColor(.secondary)
            .frame(width: 32, height: 32)
            .inCard()
            .roundedFull()
            .hoverScale(110)
            .inButtonWithAction {
                man.previous()
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

    #Preview("PreviousButton") {
        PreviousButton()
            .inRootView()
            .frame(height: 800)
    }

    #Preview("PreviousButton - Demo") {
        PreviousButton()
            .inRootView()
            .inDemoMode()
            .frame(height: 800)
    }
#endif

#if os(iOS)
    #Preview("iPhone") {
        ContentView()
            .inRootView()
    }
#endif
