import MagicKit
import SwiftUI

/**
 * App Store - 极简设计页面
 * 展示无广告、无干扰的纯净体验
 */
struct AppStoreMinimal: View {
    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 120) {
                // 左侧：标题和副标题
                VStack(alignment: .leading, spacing: 40) {
                    Spacer()

                    Text("极简设计")
                        .font(.system(size: 100, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    Text("没有广告，没有干扰。")
                        .font(.system(size: 34, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)

                    Text("专注于音乐本身，享受纯粹体验。")
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

#Preview("App Store Minimal") {
    AppStoreMinimal()
        .inMagicContainer(.macBook13, scale: 0.4)
}
