import MagicBackground
import MagicContainer
import MagicCore
import MagicUI
import SwiftUI

/// 第三个宣传图：常驻菜单栏（Menu Bar）
struct AppStoreHeroMenuBar: View {
    var body: some View {
        AppStoreHeroContainer(
            title: "常驻菜单栏",
            subtitleTop: "轻盈，不打扰。",
            subtitleBottom: "就在屏幕顶端，抬眼可见的安心。",
            overlayLogoAlignment: .topLeading,
        ) {
            AppDemo()
        }
    }
}

// MARK: - Preview

#Preview("App Store Hero") {
    AppStoreHero()
        .inMagicContainer(.macBook13, scale: 0.4)
}

#Preview("App Store Hero - One Tap Block") {
    AppStoreHeroBlock()
        .inMagicContainer(.macBook13, scale: 0.4)
}

#Preview("App Store Hero - Menu Bar") {
    AppStoreHeroMenuBar()
        .inMagicContainer(.macBook13, scale: 0.4)
}


