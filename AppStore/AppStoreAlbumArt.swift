import MagicKit
import MagicUI
import SwiftUI

/**
 * App Store - 专辑封面页面
 * 展示精美的专辑封面展示
 */
struct AppStoreAlbumArt: View {
    var body: some View {
        Text("专辑封面")
            .withPosterSubTitle("精美的专辑封面展示。")
            .withPosterBottomSubTitle("大尺寸封面，沉浸式视觉体验。")
            .withPosterPreview(
                ContentView()
                    .inRootView()
                    .inDemoMode()
                    .hideTabView()
                    .frame(width: Config.minWidth)
                    .frame(height: 800)
            )
            .withPosterLogo(false)
            .withPosterBackground(LinearGradient.pastel)
            .asPoster()
    }
}

// MARK: - Preview

#Preview("App Store Album Art") {
    AppStoreAlbumArt()
        .inMagicContainer(.macBook13, scale: 0.4)
}
