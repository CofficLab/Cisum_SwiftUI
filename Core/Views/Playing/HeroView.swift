import MagicKit
import OSLog
import SwiftUI

struct HeroView: View {
    nonisolated static let verbose = false

    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var playMan: PlayMan
    @Environment(\.demoMode) var isDemoMode

    private let titleViewHeight: CGFloat = 60

    // Demo mode 的静态演示封面
    private var demoAlbumView: some View {
        LogoView(
            background: .white.opacity(0.3),
            backgroundShape: .circle,
            size: 200
        )
    }

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                if shouldShowAlbum(geo) {
                    if isDemoMode {
                        // Demo mode: 显示静态演示封面
                        demoAlbumView
                            .frame(maxWidth: .infinity)
                            .frame(height: getAlbumHeight(geo))
                            .clipped()
                    } else {
                        playMan.makeHeroView(verbose: Self.verbose, avatarShape: .roundedRectangle(cornerRadius: 8))
                            .frame(maxWidth: .infinity)
                            .frame(height: getAlbumHeight(geo))
                    }
                }

                TitleView()
                    .frame(maxWidth: .infinity)
                    .frame(height: titleViewHeight)
            }
            .infinite()
        }
        .ignoresSafeArea(edges: Config.isDesktop ? .horizontal : .all)
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

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}
