import MagicKit
import MagicUI
import SwiftUI

/**
 * App Store 主页面
 * 展示应用核心价值和主要功能
 */
struct AppStoreHero: View {
    var body: some View {
        Text("Cisum")
            .font(.system(size: 50))
            .withPosterSubTitle("纯净播放，简单纯粹。")
            .withPosterPreview(
                ContentView()
                    .inRootView()
                    .inDemoMode()
                    .hideTabView()
                    .frame(width: Config.minWidth)
                    .frame(height: 650)
            )
            .withPosterLogo(false)
            .withPosterBackground(LinearGradient.pastel)
            .asPoster()
    }
}

// MARK: - Preview

#Preview("App Store Hero") {
    AppStoreHero()
        .inMagicContainer(.macBook13, scale: 0.4)
}
