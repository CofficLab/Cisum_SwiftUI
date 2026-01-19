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
        ZStack {
            LinearGradient(
                colors: [.blue.opacity(0.8), .blue.opacity(0.1)],
                startPoint: .top,
                endPoint: .bottom
            )

            LogoView(
                background: .white.opacity(0.1),
                backgroundShape: .circle,
                size: 200
            )
        }
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
                        playMan.makeHeroView(verbose: Self.verbose, defaultView: {
                            LogoView(background: .blue.opacity(0.1), rotationSpeed: 0.001, backgroundShape: .circle)
                        })
                        .frame(maxWidth: .infinity)
                        .frame(height: getAlbumHeight(geo))
                        .clipped()
                    }
                }

                TitleView()
                    .frame(maxWidth: .infinity)
                    .frame(height: titleViewHeight)
                    .background(Config.background(.blue))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .ignoresSafeArea(edges: Config.isDesktop ? .horizontal : .all)
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

#Preview("App - Large") {
    ContentView()
        .inRootView()
        .frame(width: 600, height: 800)
}

#Preview("App - Small") {
    ContentView()
        .inRootView()
        .frame(width: Config.minWidth, height: 700)
}

#Preview("Demo Mode") {
    ContentView()
        .inRootView()
        .inDemoMode()
        .frame(width: Config.minWidth, height: 700)
}

#if os(iOS)
    #Preview("iPhone") {
        ContentView()
            .inRootView()
    }
#endif
