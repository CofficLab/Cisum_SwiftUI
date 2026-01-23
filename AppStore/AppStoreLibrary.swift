import MagicKit
import SwiftUI

struct AppStoreLibrary: View {
    var body: some View {
        Group {
            Group {
                Text("音乐库")
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

                Text("管理你的本地音乐")
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
        .background(LinearGradient.forest.opacity(0.3))
        .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
    }
}

// MARK: - Preview

#Preview("App Store Library") {
    AppStoreLibrary()
        .inMagicContainer(.macBook13, scale: 1)
}
