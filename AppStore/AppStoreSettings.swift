import MagicUI
import SwiftUI

/**
 * App Store - 个性化设置页面
 * 展示丰富的设置选项
 */
struct AppStoreSettings: View {
    var body: some View {
        AppStoreHeroContainer(
            title: "个性定制",
            subtitleTop: "丰富的设置选项。",
            subtitleBottom: "按照你的喜好，定制专属体验。"
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

#Preview("App Store Settings") {
    AppStoreSettings()
        .inMagicContainer(.macBook13, scale: 0.2)
}
