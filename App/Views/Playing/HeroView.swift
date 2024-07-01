import SwiftUI
import OSLog

struct HeroView: View {
    @EnvironmentObject var app: AppManager
    @EnvironmentObject var playMan: AudioMan

    @State var topAlbumHeight: CGFloat = 0
    
    var verbose = false
    var showErrorView: Bool { false }
    var showTitleView: Bool { playMan.asset != nil }

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                if shouldShowAlbum(geo) {
                    PlayingAlbum()
                        .frame(maxWidth: .infinity)
                        .frame(maxHeight: geo.size.width)
                        .background(GeometryReader { geo in
                            Config.background(.yellow)
                                .onAppear {
                                    self.topAlbumHeight = geo.size.height
                                    if verbose {
                                        os_log("\(self.topAlbumHeight)")
                                    }
                                }
                                .onDisappear {
                                    self.topAlbumHeight = 0
                                    if verbose {
                                        os_log("\(self.topAlbumHeight)")
                                    }
                                }
                                .onChange(of: geo.size.width) {
                                    self.topAlbumHeight = geo.size.height
                                    if verbose {
                                        os_log("\(self.topAlbumHeight)")
                                    }
                                }
                                .onChange(of: geo.size.height) {
                                    self.topAlbumHeight = geo.size.height
                                    if verbose {
                                        os_log("\(self.topAlbumHeight)")
                                    }
                                }
                        })
                }

                if showTitleView {
                    TitleView(width: getTitleViewWidth(geo))
                        .frame(maxWidth: .infinity)
                        .frame(height: getTitleViewHeight(geo))
                        .background(Config.background(.red))
                        .frame(alignment: .center)
                        .background(Config.background(.indigo))
                }
            }
            .onChange(of: geo.size.width) {
                if verbose {
                    os_log("Geo withd \(geo.size.width)")
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(maxHeight: .infinity)
    }

    func getTitleViewHeight(_ geo: GeometryProxy) -> CGFloat {
        if shouldShowAlbum(geo) == false {
            return geo.size.height
        }
        
        return max(geo.size.height - geo.size.width, 50)
    }

    // MARK: 标题栏的宽度

    private func getTitleViewWidth(_ geo: GeometryProxy) -> CGFloat {
        // 理想宽度
        var width = geo.size.width

        // 如果高度特别小，宽度也减小一些以让字体变小
        if getTitleViewHeight(geo) <= Config.minHeight * 1.5 {
            width = Config.minWidth
        }

        return width
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
