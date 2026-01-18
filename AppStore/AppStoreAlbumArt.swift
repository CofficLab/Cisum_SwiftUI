import MagicUI
import SwiftUI

/**
 * App Store - 专辑封面页面
 * 展示精美的专辑封面展示
 */
struct AppStoreAlbumArt: View {
    var body: some View {
        AppStoreHeroContainer(
            title: "专辑封面",
            subtitleTop: "精美的专辑封面展示。",
            subtitleBottom: "大尺寸封面，沉浸式视觉体验。"
        ) {
            ContentView()
                .inRootView()
                .inDemoMode()
                .hideTabView()
                .frame(width: Config.minWidth)
                .frame(height: 800)
        }
    }
}

// MARK: - Preview

#Preview("App Store Album Art") {
    AppStoreAlbumArt()
        .inMagicContainer(.macBook13, scale: 0.2)
}
