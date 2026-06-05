import PluginRegistry
import SwiftUI

struct iPhoneAlbumArt: View {
    var body: some View {
        GeometryReader { geo in
            VStack {
                Group {
                    Text("Cisum")
                        .asPosterTitleForIPhone()

                    Text("自动获取专辑封面")
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

#Preview("App Store iOS - Album Art - iPhone 5.5") {
    iPhoneAlbumArt()
        .cisumPreviewContainer(.cisumIPhone55, scale: 0.45)
}

#Preview("App Store iOS - Album Art - iPhone 6.5") {
    iPhoneAlbumArt()
        .cisumPreviewContainer(.cisumIPhone65, scale: 0.45)
}

#Preview("App Store iOS - Album Art - iPhone 6.9") {
    iPhoneAlbumArt()
        .cisumPreviewContainer(.cisumIPhone69, scale: 0.45)
}
