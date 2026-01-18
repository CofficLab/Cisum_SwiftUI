import MagicKit
import SwiftUI

/**
 * App Store - 本地音乐页面
 * 展示播放本地音乐文件的功能
 */
struct AppStoreLocalFiles: View {
    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 120) {
                // 左侧：标题和副标题
                VStack(alignment: .leading, spacing: 40) {
                    Spacer()

                    Text("本地音乐")
                        .font(.system(size: 100, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    Text("播放你的音乐文件。")
                        .font(.system(size: 34, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)

                    Text("支持多种音频格式，无需网络即可播放。")
                        .font(.system(size: 24))
                        .foregroundColor(.secondary)

                    Spacer()
                }
                .frame(width: geo.size.width * 0.3)

                // 右侧：预览内容
                ContentView()
                    .inRootView()
                    .inDemoMode()
                    .showTabView()
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

#Preview("App Store Local Files") {
    AppStoreLocalFiles()
        .inMagicContainer(.macBook13, scale: 0.4)
}
