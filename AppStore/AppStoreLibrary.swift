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
                .roundedLarge()
                .shadowSm()
        }
        .magicCentered()
        .withBackgroundDecorations()
        .background(LinearGradient.forest.opacity(0.3))
    }
}

// MARK: - Preview

#Preview("App Store Library") {
    AppStoreLibrary()
        .inMagicContainer(.macBook13, scale: 1)
}
