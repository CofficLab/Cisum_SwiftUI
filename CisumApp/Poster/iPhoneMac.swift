import PluginRegistry
import SwiftUI

struct iPhoneMac: View {
    var body: some View {
        GeometryReader { geo in
            VStack {
                Group {
                    Text("Cisum")
                        .asPosterTitleForIPhone()

                    Text("macOS 上也精彩")
                        .asPosterSubTitleForIPhone()
                }
                .cisumVStackCenter()
                .frame(height: geo.size.height * 0.3)

                LogoView()
                    .background(Config.rootBackground)
                    .cisumShadowSm()
                    .inIMacScreen()
                    .frame(height: geo.size.height * 0.7)
            }.cisumHStackCenter()
        }
        .inPosterContainer()
    }
}

// MARK: - Preview

#Preview("App Store iOS - Mac - iPhone 5.5") {
    iPhoneMac()
        .cisumPreviewContainer(.cisumIPhone55, scale: 0.45)
}

#Preview("App Store iOS - Mac - iPhone 6.5") {
    iPhoneMac()
        .cisumPreviewContainer(.cisumIPhone65, scale: 0.45)
}

#Preview("App Store iOS - Mac - iPhone 6.9") {
    iPhoneMac()
        .cisumPreviewContainer(.cisumIPhone69, scale: 0.45)
}
