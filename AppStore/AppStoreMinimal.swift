import MagicKit
import MagicUI
import SwiftUI

/**
 * App Store - 极简设计页面
 * 展示无广告、无干扰的纯净体验
 */
struct AppStoreMinimal: View {
    var body: some View {
        Text("极简设计")
            .font(.system(size: 50))
            .withPosterSubTitle("没有广告，没有干扰。")
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

#Preview("App Store Minimal") {
    AppStoreMinimal()
        .inMagicContainer(.macBook13, scale: 0.4)
}
