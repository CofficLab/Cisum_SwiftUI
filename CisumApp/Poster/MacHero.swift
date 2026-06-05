import PluginRegistry
import SwiftUI

struct AppStoreHero: View {
    var body: some View {
        GeometryReader { geo in
            HStack {
                Group {
                    Text("Cisum")
                        .asPosterTitle()

                    Text("简单纯粹的音乐播放器")
                        .asPosterSubTitle()
                }
                .frame(width: geo.size.width * 0.5)
                .cisumVStackCenter()

                ZStack {
                    ContentLayout()
                        .showDetail()
                        .inRootView()
                        .inDemoMode()
                        .frame(width: max(Config.minWidth, geo.size.width * 0.15))
                        .frame(height: geo.size.height * 0.4)
                        .cisumRoundedLarge()
                        .rotation3DEffect(
                            .degrees(-8),
                            axis: (x: 0, y: 0, z: 1),
                            anchor: .bottomLeading,
                            perspective: 1.0
                        )
                        .offset(x: -70, y: -20)
                        .cisumShadowSm()
                        .scaleEffect(2)

                    ContentLayout()
                        .hideDetail()
                        .inRootView()
                        .inDemoMode()
                        .frame(width: max(Config.minWidth, geo.size.width * 0.15))
                        .frame(height: geo.size.height * 0.4)
                        .background(.background.opacity(0.5))
                        .cisumRoundedLarge()
                        .cisumShadowXl()
                        .rotation3DEffect(
                            .degrees(8),
                            axis: (x: 0, y: 0, z: 1),
                            anchor: .bottomLeading,
                            perspective: 1.0
                        )
                        .offset(x: 10, y: -20)
                        .scaleEffect(2)
                }
                .frame(width: geo.size.width * 0.5)
            }
        }
        .inPosterContainer()
    }
}

// MARK: - Preview

#Preview("App Store Hero") {
    AppStoreHero()
        .cisumPreviewContainer(.cisumMacBook13, scale: 0.5)
}
