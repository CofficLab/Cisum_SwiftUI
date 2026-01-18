import MagicKit
import MagicUI
import SwiftUI

/**
 * App Store - 收藏功能页面
 * 展示收藏喜爱的歌曲功能
 */
struct AppStoreCollection: View {
    var body: some View {
        Text("收藏喜爱")
            .withPosterSubTitle("标记你喜爱的歌曲。")
            .withPosterBottomSubTitle("一键收藏，随时重温你的最爱。")
            .withPosterPreview(
                ContentView()
                    .inRootView()
                    .inDemoMode()
                    .frame(width: Config.minWidth)
                    .frame(height: 800)
            )
            .withPosterLogo(false)
            .withPosterBackground(LinearGradient.pastel)
            .asPoster()
    }
}

// MARK: - Preview

#Preview("App Store Collection") {
    AppStoreCollection()
        .inMagicContainer(.macBook13, scale: 0.4)
}
