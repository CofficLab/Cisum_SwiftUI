import MagicBackground
import MagicContainer
import MagicCore
import MagicUI
import SwiftUI

/**
 * App Store 主页面
 * 展示应用核心价值和主要功能
 */
struct AppStoreHero: View {
    var body: some View {
        AppStoreHeroContainer(
            title: "Title",
            subtitleTop: "实时监控，简单可靠。",
            subtitleBottom: "看得见的网络安全，清晰而从容。"
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
