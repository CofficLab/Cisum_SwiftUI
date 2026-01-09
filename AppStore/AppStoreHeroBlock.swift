import MagicKit
import MagicUI
import SwiftUI

/// 第二个宣传图：一键禁止联网
struct AppStoreHeroBlock: View {
    var body: some View {
        AppStoreHeroContainer(
            title: "一键禁止联网",
            subtitleTop: "点击，即安心。",
            subtitleBottom: "无需设置，重要时刻，立刻静音网络。"
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

