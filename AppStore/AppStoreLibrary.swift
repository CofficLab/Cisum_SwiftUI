import MagicKit
import SwiftUI

/**
 * App Store - 音乐库页面
 * 展示本地音乐管理功能
 */
struct AppStoreLibrary: View {
    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 120) {
                // 左侧：标题和副标题
                VStack(alignment: .leading, spacing: 40) {
                    Spacer()

                    Text("音乐库")
                        .font(.system(size: 100, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    Text("管理你的本地音乐。")
                        .font(.system(size: 34, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)

                    Text("导入、整理、播放，一切尽在掌握。")
                        .font(.system(size: 24))
                        .foregroundColor(.secondary)

                    Spacer()
                }
                .frame(width: geo.size.width * 0.3)

                // 右侧：预览内容
                ContentView()
                    .inRootView()
                    .inDemoMode()
                    .frame(width: Config.minWidth)
                    .frame(height: 650)
                    .background(.background.opacity(0.5))
                    .magicRoundedLarge()
            }
            .padding(.horizontal, 60)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .withBackgroundDecorations()
        .background(LinearGradient.forest)
    }
}

// MARK: - Preview

#Preview("App Store Library") {
    AppStoreLibrary()
        .inMagicContainer(.macBook13, scale: 0.4)
}
