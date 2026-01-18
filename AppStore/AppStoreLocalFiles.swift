import MagicUI
import SwiftUI

/**
 * App Store - 本地音乐页面
 * 展示播放本地音乐文件的功能
 */
struct AppStoreLocalFiles: View {
    var body: some View {
        AppStoreHeroContainer(
            title: "本地音乐",
            subtitleTop: "播放你的音乐文件。",
            subtitleBottom: "支持多种音频格式，无需网络即可播放。"
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

#Preview("App Store Local Files") {
    AppStoreLocalFiles()
        .inMagicContainer(.macBook13, scale: 0.2)
}
