import MagicKit
import SwiftUI

struct AppStoreMinimal: View {
    var body: some View {
        Group {
            Group {
                Text("极简设计")
                    .bold()
                    .font(.system(size: 100, design: .rounded))
                    .magicOceanGradient()
                    .padding(.bottom, 20)

                Text("没有广告，没有干扰")
                    .font(.system(size: 34, design: .rounded))
                    .foregroundColor(.primary)
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

#Preview("App Store Minimal") {
    AppStoreMinimal()
        .inMagicContainer(.macBook13, scale: 1)
}
