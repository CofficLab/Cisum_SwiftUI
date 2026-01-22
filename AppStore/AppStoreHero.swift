import MagicKit
import SwiftUI

struct AppStoreHero: View {
    var body: some View {
        Group {
            Group {
                Text("Cisum")
                    .bold()
                    .font(.system(size: 100, design: .rounded))
                    .magicOceanGradient()
                    .padding(.bottom, 20)

                Text("纯净播放，简单纯粹")
                    .font(.system(size: 50, design: .rounded))
                    .foregroundColor(.secondary)
            }.inMagicVStackCenter()

            Spacer(minLength: 100)

            ContentView()
                .inRootView()
                .inDemoMode()
                .hideTabView()
                .frame(width: Config.minWidth)
                .frame(height: 650)
                .background(.background.opacity(0.5))
                .magicRoundedLarge()
                .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
        }
        .magicCentered()
        .withBackgroundDecorations()
        .background(LinearGradient.pastel)
    }
}

// MARK: - Preview

#Preview("App Store Hero") {
    AppStoreHero()
        .inMagicContainer(.macBook13, scale: 1)
}
