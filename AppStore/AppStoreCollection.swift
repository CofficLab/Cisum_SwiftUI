import MagicKit
import SwiftUI

struct AppStoreCollection: View {
    var body: some View {
        Group {
            Group {
                Text("收藏喜爱")
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

                Text("标记你喜爱的歌曲")
                    .font(.system(size: 50, design: .rounded))
                    .foregroundColor(.secondary)
            }
            .inMagicVStackCenter()

            Spacer(minLength: 100)

            ContentView()
                .inRootView()
                .inDemoMode()
                .frame(width: Config.minWidth)
                .frame(height: 650)
                .background(.background.opacity(0.5))
                .magicRoundedLarge()
        }
        .magicCentered()
        .withBackgroundDecorations()
        .background(LinearGradient.pastel)
    }
}

// MARK: - Preview

#Preview("App Store Collection") {
    AppStoreCollection()
        .inMagicContainer(.macBook13, scale: 1)
}
