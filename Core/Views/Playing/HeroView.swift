import OSLog
import SwiftUI

struct HeroView: View {
    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var playMan: PlayMan

    private let titleViewHeight: CGFloat = 60
    private let verbose = true

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                if shouldShowAlbum(geo) {
                    playMan.makeHeroView()
                        .frame(maxWidth: .infinity)
                        .frame(height: getAlbumHeight(geo))
                        .clipped()
                        .background(Config.background(.indigo))
                }

                TitleView()
                    .frame(maxWidth: .infinity)
                    .frame(height: titleViewHeight)
                    .background(Config.background(.blue))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .ignoresSafeArea()
        .foregroundStyle(.white)
    }

    // 计算专辑封面高度
    private func getAlbumHeight(_ geo: GeometryProxy) -> CGFloat {
        // 总高度减去标题高度就是封面可用空间
        return max(0, geo.size.height - titleViewHeight)
    }

    private func shouldShowAlbum(_ geo: GeometryProxy) -> Bool {
        !app.rightAlbumVisible && geo.size.height > Config.minHeightToShowAlbum
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}

#Preview("500") {
    LayoutView(width: 500)
}
