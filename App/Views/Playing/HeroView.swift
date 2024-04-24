import SwiftUI

struct HeroView: View {
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var app: AppManager

    @State var topAlbumHeight: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                if shouldShowAlbum(geo) {
                    PlayingAlbum()
                        .frame(maxWidth: .infinity)
                        .frame(maxHeight: geo.size.width)
                        .background(GeometryReader { geo in
                            ViewConfig.background(.yellow)
                                .onAppear {
                                    self.topAlbumHeight = geo.size.height
                                    print(self.topAlbumHeight)
                                }
                                .onDisappear {
                                    self.topAlbumHeight = 0
                                    print(self.topAlbumHeight)
                                }
                                .onChange(of: geo.size.width) {
                                    self.topAlbumHeight = geo.size.height
                                    print(self.topAlbumHeight)
                                }
                                .onChange(of: geo.size.height) {
                                    self.topAlbumHeight = geo.size.height
                                    print(self.topAlbumHeight)
                                }
                        })
                }

                if audioManager.showTitleView {
                    TitleView(width: getTitleViewWidth(geo))
                        .frame(maxWidth: .infinity)
                        .frame(height: getTitleViewHeight(geo))
                        .background(ViewConfig.background(.red))
                        .frame(alignment: .center)
                        .background(ViewConfig.background(.indigo))
                }
            }
            .onChange(of: geo.size.width) {
                print("Geo withd \(geo.size.width)")
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
        if getTitleViewHeight(geo) <= AppConfig.minHeight * 1.5 {
            width = AppConfig.minWidth
        }

        return width
    }

    private func shouldShowAlbum(_ geo: GeometryProxy) -> Bool {
        !app.rightAlbumVisible && geo.size.height > ViewConfig.minHeightToShowAlbum
    }
}

#Preview("500") {
    LayoutView(width: 500)
}
