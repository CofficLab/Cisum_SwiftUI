import MagicKit
import SwiftUI

struct AppStoreLocalFiles: View {
    var body: some View {
        Group {
            Group {
                Text("本地音乐")
                    .bold()
                    .font(.system(size: 100, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .padding(.bottom, 20)

                Text("播放你的音乐文件")
                    .font(.system(size: 50, design: .rounded))
                    .foregroundColor(.secondary)
            }
            .inMagicVStackCenter()

            Spacer(minLength: 100)

            ContentView()
                .inRootView()
                .inDemoMode()
                .showTabView()
                .frame(width: Config.minWidth)
                .frame(height: 650)
                .background(.background.opacity(0.5))
                .magicRoundedLarge()
        }
        .magicCentered()
        .withBackgroundDecorations()
        .background(LinearGradient.pastel)
        .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
    }
}

// MARK: - Preview

#Preview("App Store Local Files") {
    AppStoreLocalFiles()
        .inMagicContainer(.macBook13, scale: 1)
}
