import MagicKit
import SwiftUI

/**
 * App Store 主页面
 * 展示应用核心价值和主要功能
 */
struct AppStoreHero: View {
    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 120) {
                // 左侧：标题和副标题
                VStack(alignment: .leading, spacing: 40) {
                    Spacer()

                    Text("Cisum")
                        .font(.system(size: 100, weight: .bold, design: .rounded))
                        .magicOceanGradient()

                    Text("纯净播放，简单纯粹。")
                        .font(.system(size: 34, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)

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

#Preview("App Store Hero") {
    AppStoreHero()
        .inMagicContainer(.macBook13, scale: 0.4)
    
}
