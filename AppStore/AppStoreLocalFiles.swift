import MagicKit
import MagicUI
import SwiftUI

/**
 * App Store - 本地音乐页面
 * 展示播放本地音乐文件的功能
 */
struct AppStoreLocalFiles: View {
    var body: some View {
        Text("本地音乐")
            .font(.system(size: 50))
            .withPosterSubTitle("播放你的音乐文件。")
            .withPosterBottomSubTitle("支持多种音频格式，无需网络即可播放。")
            .withPosterPreview(
                ContentView()
                    .showTabView()
                    .inRootView()
                    .inDemoMode()
                    .frame(width: Config.minWidth)
                    .frame(height: 650)
            )
            .withPosterLogo(false)
            .withPosterBackground(LinearGradient.pastel)
            .asPoster()
    }
}

// MARK: - Preview

#Preview("App Store Local Files") {
    AppStoreLocalFiles()
        .inMagicContainer(.macBook13, scale: 0.4)
}
