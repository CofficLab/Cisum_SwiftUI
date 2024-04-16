import SwiftUI

struct ControlView: View {
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var appManager: AppManager

    var showOperationView = false

    @State var topAlbumVisible = false
    @State var topAlbumHeight: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                VStack(spacing: 0) {
                    PlayingAlbum()
                        .frame(height: getAlbumHeight(geo))
                        //.background(AppConfig.makeBackground(.red))

                    if audioManager.showTitleView {
                        TitleView(geo: geo)
                            .frame(height: getTitleHeight(geo))
                            .frame(maxHeight: .infinity)
                            .background(AppConfig.makeBackground(.red))
                    }

                    if audioManager.showErrorView {
                        StateView()
                            .frame(height: getStateHeight(geo))
                            .frame(maxHeight: .infinity)
                            .background(AppConfig.makeBackground(.red))
                    }

                    if showOperationView {
                        OperationView(geo: geo)
                            .frame(height: getOperationHeight(geo))
                    }

                    Spacer()

                    SliderView()
                        .frame(height: getSliderHeight(geo))

                    BtnsView()
                        .frame(height: getButtonsHeight(geo))
                }

                // MARK: 横向的封面图

                if shouldShowRightAlbum(geo) {
                    // 最大宽度=控制栏的高度+系统标题栏高度
                    HStack {
                        Spacer()
                        PlayingAlbum()
                            //.background(AppConfig.makeBackground(.yellow))
                    }.frame(maxWidth: geo.size.height * 1.3)
                }
            }
            .padding(.bottom, 0)
            .padding(.horizontal, 0)
            .frame(maxHeight: .infinity)
        }
        .foregroundStyle(.white)
        .ignoresSafeArea()
        .frame(minHeight: AppConfig.controlViewMinHeight)
    }

    // MARK: 封面图的高度

    private func getAlbumHeight(_ geo: GeometryProxy) -> CGFloat {
        // 默认不显示，当空间充足再显示

        if !shouldShowTopAlbum(geo) {
            AppConfig.mainQueue.async {
                topAlbumVisible = false
                topAlbumHeight = 0
            }
            return 0
        }

        let height = min(max(0, geo.size.height
                - getTitleHeight(geo)
                - getStateHeight(geo)
                - getOperationHeight(geo)
                - getSliderHeight(geo)
                - getButtonsHeight(geo)), geo.size.width)

        AppConfig.mainQueue.async {
            topAlbumVisible = true
            topAlbumHeight = height
        }

        return height
    }

    // MARK: 标题的高度

    private func getTitleHeight(_ geo: GeometryProxy) -> CGFloat {
        audioManager.showTitleView ? 50 : 0
    }

    // MARK: 操作栏的高度

    private func getOperationHeight(_ geo: GeometryProxy) -> CGFloat {
        if showOperationView == false {
            return 0
        }

        return getButtonsHeight(geo) / 1.4
    }

    // MARK: 进度条的高度

    private func getSliderHeight(_ geo: GeometryProxy) -> CGFloat {
        return 36
    }

    // MARK: 控制按钮的高度

    private func getButtonsHeight(_ geo: GeometryProxy) -> CGFloat {
        if topAlbumVisible {
            return min(geo.size.width / 5, geo.size.height
                - getTitleHeight(geo)
                - topAlbumHeight
                - getSliderHeight(geo))
        }

        return min(
            geo.size.width / 5,
            geo.size.height / 2,
            geo.size.height
                - getTitleHeight(geo)
                - getSliderHeight(geo)
        )
    }

    // MARK: 播放状态的高度

    private func getStateHeight(_ geo: GeometryProxy) -> CGFloat {
        if audioManager.showErrorView == false {
            return 0
        }
        
        if geo.size.height <= AppConfig.minHeight {
            return 24
        }

        if geo.size.height <= AppConfig.minWidth + 100 {
            return 36
        }

        return 48
    }

    private func shouldShowRightAlbum(_ geo: GeometryProxy) -> Bool {
        geo.size.width > 1200
    }

    private func shouldShowTopAlbum(_ geo: GeometryProxy) -> Bool {
        !shouldShowRightAlbum(geo) &&
            geo.size.height
            - getTitleHeight(geo)
            - getOperationHeight(geo)
            - getSliderHeight(geo)
            - getButtonsHeight(geo)
            - getStateHeight(geo)
            > geo.size.width
    }
}

#Preview("App") {
    AppPreview()
}

#Preview("Layout") {
    LayoutView()
}

#Preview("Layout-500") {
    LayoutView(500)
        .frame(width: AppConfig.minWidth + 500)
}

#Preview("Layout-1500") {
    LayoutView(1500)
        .frame(width: AppConfig.minWidth + 1500)
}
