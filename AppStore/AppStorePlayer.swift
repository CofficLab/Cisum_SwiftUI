import MagicKit
import SwiftUI

struct AppStorePlayer: View {
    var body: some View {
        Group {
            Group {
                Text("播放控制")
                    .bold()
                    .font(.system(size: 100, design: .rounded))
                    .magicSunsetGradient()
                    .padding(.bottom, 20)

                Text("简单直观的控制方式")
                    .font(.system(size: 50, design: .rounded))
                    .foregroundColor(.secondary)
            }
            .inMagicVStackCenter()

            Spacer(minLength: 100)

            ContentView()
                .inRootView()
                .inDemoMode()
                .hideTabView()
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

#Preview("App Store Player") {
    AppStorePlayer()
        .inMagicContainer(.macBook13, scale: 1)
}
