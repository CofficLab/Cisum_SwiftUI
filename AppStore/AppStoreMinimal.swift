import MagicUI
import SwiftUI

/**
 * App Store - 极简设计页面
 * 展示无广告、无干扰的纯净体验
 */
struct AppStoreMinimal: View {
    var body: some View {
        AppStoreHeroContainer(
            title: "极简设计",
            subtitleTop: "没有广告，没有干扰。",
            subtitleBottom: "专注于音乐本身，享受纯粹体验。"
        ) {
            ContentView()
                .inRootView()
                .inDemoMode()
                .hideTabView()
                .frame(width: Config.minWidth)
                .frame(height: 700)
        }
    }
}

// MARK: - Preview

#Preview("App Store Minimal") {
    AppStoreMinimal()
        .inMagicContainer(.macBook13, scale: 0.2)
}
