import MagicKit
import MagicUI
import SwiftUI

/**
 * App Store - 个性化设置页面
 * 展示丰富的设置选项
 */
struct AppStoreSettings: View {
    var body: some View {
        Text("个性定制")
            .withPosterSubTitle("丰富的设置选项。")
            .withPosterBottomSubTitle("按照你的喜好，定制专属体验。")
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

#Preview("App Store Settings") {
    AppStoreSettings()
        .inMagicContainer(.macBook13, scale: 0.4)
}
