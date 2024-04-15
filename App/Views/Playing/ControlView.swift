import SwiftUI

struct ControlView: View {
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var appManager: AppManager

    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                VStack(spacing: 0) {
                    Spacer()
                    if shouldShowTopAlbum(geo) {
                        PlayingAlbum()
                            .frame(height: getAlbumHeight(geo))
                            .background(AppConfig.makeBackground())
                    }

                    TitleView(geo: geo)
                        .frame(height: getTitleHeight(geo))
                        .background(AppConfig.makeBackground(.cyan))

                    if audioManager.showErrorView {
                        ErrorView()
                            .frame(height: getErrorsHeight(geo))
                            .background(AppConfig.makeBackground())
                    }

//                    Spacer()

                    OperationView(geo: geo)
                        .frame(height: getOperationHeight(geo))
                        .background(AppConfig.makeBackground())

                    SliderView()
                        .frame(height: getSliderHeight(geo))
                        .background(AppConfig.makeBackground())

                    Spacer().frame(height: getGapHeightBetweenSliderAndButtons(geo))

                    BtnsView()
                        .frame(height: getButtonsHeight(geo))
                        .background(AppConfig.makeBackground())

                    // MARK: 播放控制底部的状态栏

                    if UIConfig.isDesktop {
                        StateView()
                            .frame(height: getStateHeight(geo))
                            .background(AppConfig.makeBackground(.brown))
                    }

                    // MARK: 底部的空白

                    VStack {
                    }.frame(minHeight: getBottomPaddingHeight(geo))
                }
                .background(AppConfig.makeBackground(.yellow))

                // MARK: 横向的封面图

                if shouldShowRightAlbum(geo) {
                    // 最大宽度=控制栏的高度+系统标题栏高度
                    HStack {
                        Spacer()
                        PlayingAlbum()
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
//        .frame(maxHeight: AppConfig.canResize ? AppConfig.controlViewMinHeight : .infinity)
    }

    // MARK: 封面图的高度

    private func getAlbumHeight(_ geo: GeometryProxy) -> CGFloat {
        // 默认不显示，当空间充足再显示

        if !shouldShowTopAlbum(geo) {
            return 0
        }

        return min(max(0, geo.size.height
                - getTitleHeight(geo)
                - getErrorsHeight(geo)
                - getOperationHeight(geo)
                - getSliderHeight(geo)
                - getButtonsHeight(geo)
                - getStateHeight(geo)
        ), geo.size.width)
    }

    // MARK: 标题的高度

    private func getTitleHeight(_ geo: GeometryProxy) -> CGFloat {
        return 80
//        geo.size.height
//            - getErrorsHeight(geo)
//            - getOperationHeight(geo)
//            - getSliderHeight(geo)
//            - getButtonsHeight(geo)
//            - getStateHeight(geo)
    }

    // MARK: 操作栏的高度

    private func getOperationHeight(_ geo: GeometryProxy) -> CGFloat {
        getButtonsHeight(geo) / 1.4
    }

    // MARK: 错误提示的高度

    private func getErrorsHeight(_ geo: GeometryProxy) -> CGFloat {
        audioManager.showErrorView ? geo.size.height / 10 : 0
    }

    // MARK: 进度条的高度

    private func getSliderHeight(_ geo: GeometryProxy) -> CGFloat {
        if geo.size.height <= AppConfig.minHeight {
            return 32
        }

        if geo.size.height <= AppConfig.minWidth + 100 {
            return 48
        }

        return 56
    }

    private func getGapHeightBetweenSliderAndButtons(_ geo: GeometryProxy) -> CGFloat {
        return 1
    }

    // MARK: 控制按钮的高度

    private func getButtonsHeight(_ geo: GeometryProxy) -> CGFloat {
        min(geo.size.width / 5, geo.size.height / 6.5)
    }

    // MARK: 播放状态的高度

    private func getStateHeight(_ geo: GeometryProxy) -> CGFloat {
        if geo.size.height <= AppConfig.minHeight {
            return 24
        }

        if geo.size.height <= AppConfig.minWidth + 100 {
            return 36
        }

        return 48
    }

    // MARK: 底部的空白的高度

    private func getBottomPaddingHeight(_ geo: GeometryProxy) -> CGFloat {
        if appManager.showDB || UIConfig.isDesktop {
            return 0
        }

        return 30
    }

    private func shouldShowRightAlbum(_ geo: GeometryProxy) -> Bool {
        geo.size.width > 1500
    }

    private func shouldShowTopAlbum(_ geo: GeometryProxy) -> Bool {
        !shouldShowRightAlbum(geo) &&
            geo.size.height
            - getTitleHeight(geo)
            - getErrorsHeight(geo)
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
