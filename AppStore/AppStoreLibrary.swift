import MagicKit
import MagicUI
import SwiftUI

/**
 * App Store - 音乐库页面
 * 展示本地音乐管理功能
 */
struct AppStoreLibrary: View {
    var body: some View {
        Text("音乐库")
            .showTabView()
            .withPosterSubTitle("管理你的本地音乐。")
            .withPosterBottomSubTitle("导入、整理、播放，一切尽在掌握。")
            .withPosterPreview(
                ContentView()
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

#Preview("App Store Library") {
    AppStoreLibrary()
        .inMagicContainer(.macBook13, scale: 0.4)
}
