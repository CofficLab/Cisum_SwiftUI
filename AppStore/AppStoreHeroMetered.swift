import MagicUI
import MagicKit
import SwiftUI

/// 第四个宣传图：用流量上网时，按需禁止部分应用联网
struct AppStoreHeroMetered: View {
    var body: some View {
        AppStoreHeroContainer(
            title: "按需连接",
            subtitleTop: "用流量上网时，更省心。",
            subtitleBottom: "你可以为部分 App 关闭网络访问，避免不必要的消耗与打扰。",
            overlayLogoAlignment: .topLeading
        ) {
            // 右侧用列表示意，并高亮一个“禁止联网”的状态
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

#Preview("App Store Hero - Metered") {
    AppStoreHeroMetered()
        .inMagicContainer(.macBook13, scale: 0.4)
}


