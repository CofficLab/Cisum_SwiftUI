import PluginRegistry
import SwiftUI

struct iPhoneHero: View {
    var body: some View {
        GeometryReader { geo in
            VStack {
                Group {
                    Text("Cisum")
                        .asPosterTitleForIPhone()

                    Text("简单纯粹的音乐播放器")
                        .asPosterSubTitleForIPhone()
                }
                .cisumVStackCenter()
                .frame(height: geo.size.height * 0.3)

                ContentLayout()
                    .showDetail()
                    .inRootView()
                    .inDemoMode()
                    .frame(width: Config.minWidth + 100)
                    .frame(height: geo.size.height * 0.3)
                    .cisumRoundedLarge()
                    .cisumShadowSm()
                    .scaleEffect(2)
                    .frame(height: geo.size.height * 0.7)
            }.cisumHStackCenter()
        }
        .inPosterContainer()
    }
}

// MARK: - Preview

#Preview("App Store iOS - Hero - iPhone 5.5") {
    iPhoneHero()
        .cisumPreviewContainer(.cisumIPhone55, scale: 0.45)
}

#Preview("App Store iOS - Hero - iPhone 6.5") {
    iPhoneHero()
        .cisumPreviewContainer(.cisumIPhone65, scale: 0.45)
}

#Preview("App Store iOS - Hero - iPhone 6.9") {
    iPhoneHero()
        .cisumPreviewContainer(.cisumIPhone69, scale: 0.45)
}
