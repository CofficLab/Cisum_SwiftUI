import MagicUI
import SwiftUI

/**
 * App Store - 音乐库页面
 * 展示本地音乐管理功能
 */
struct AppStoreLibrary: View {
    var body: some View {
        AppStoreHeroContainer(
            title: "音乐库",
            subtitleTop: "管理你的本地音乐。",
            subtitleBottom: "导入、整理、播放，一切尽在掌握。"
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

#Preview("App Store Library") {
    AppStoreLibrary()
        .inMagicContainer(.macBook13, scale: 0.2)
}
