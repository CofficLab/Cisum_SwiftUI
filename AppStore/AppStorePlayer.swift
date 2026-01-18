import MagicKit
import MagicUI
import SwiftUI

/**
 * App Store - 播放控制页面
 * 展示简洁的播放控制界面
 */
struct AppStorePlayer: View {
    var body: some View {
        Text("播放控制")
            .showTabView()
            .withPosterSubTitle("简单直观的控制方式。")
            .withPosterBottomSubTitle("播放、暂停、上一曲、下一曲，一触即达。")
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

#Preview("App Store Player") {
    AppStorePlayer()
        .inMagicContainer(.macBook13, scale: 0.4)
}
