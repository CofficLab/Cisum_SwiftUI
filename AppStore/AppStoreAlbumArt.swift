import MagicKit
import SwiftUI

/**
 * App Store - 专辑封面页面
 * 展示精美的专辑封面展示
 */
struct AppStoreAlbumArt: View {
    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 120) {
                // 左侧：标题和副标题
                VStack(alignment: .leading, spacing: 40) {
                    Spacer()

                    Text("专辑封面")
                        .font(.system(size: 100, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    Text("精美的专辑封面展示。")
                        .font(.system(size: 34, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)

                    Text("大尺寸封面，沉浸式视觉体验。")
                        .font(.system(size: 24))
                        .foregroundColor(.secondary)

                    Spacer()
                }
                .frame(width: geo.size.width * 0.3)

                // 右侧：预览内容
                ContentView()
                    .inRootView()
                    .inDemoMode()
                    .hideTabView()
                    .frame(width: Config.minWidth)
                    .frame(height: 650)
                    .background(.background.opacity(0.5))
                    .magicRoundedLarge()
            }
            .padding(.horizontal, 60)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .withBackgroundDecorations()
        .background(LinearGradient.pastel)
    }
}

// MARK: - Preview

#Preview("App Store Album Art") {
    AppStoreAlbumArt()
        .inMagicContainer(.macBook13, scale: 0.4)
}
