import MagicUI
import SwiftUI

/**
 * App Store - 收藏功能页面
 * 展示收藏喜爱的歌曲功能
 */
struct AppStoreCollection: View {
    var body: some View {
        AppStoreHeroContainer(
            title: "收藏喜爱",
            subtitleTop: "标记你喜爱的歌曲。",
            subtitleBottom: "一键收藏，随时重温你的最爱。"
        ) {
            ContentView()
                .inRootView()
                .inDemoMode()
                .frame(width: Config.minWidth)
                .frame(height: 800)
        }
    }
}

// MARK: - Preview

#Preview("App Store Collection") {
    AppStoreCollection()
        .inMagicContainer(.macBook13, scale: 0.2)
}
