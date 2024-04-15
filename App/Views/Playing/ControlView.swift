import SwiftUI

struct ControlView: View {
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var appManager: AppManager

    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                VStack(spacing: 0) {
                    if shouldShowTopAlbum(geo) {
                        PlayingAlbum()
                            .frame(height: getAlbumHeight(geo))
                            .background(.red.opacity(0.0))
                    }

                    TitleView(geo: geo)
                        .frame(height: getTitleHeight(geo))
                        .background(.red.opacity(0.0))

                    OperationView(geo: geo)
                        .frame(height: getOperationHeight(geo))
                        .background(.red.opacity(0.0))

                    ErrorView()
                        .frame(height: getErrorsHeight(geo))
                        .background(.red.opacity(0.0))

                    SliderView()
                        .frame(height: getSliderHeight(geo))
                        .background(.red.opacity(0.0))
                    BtnsView()
//                        .frame(height: getButtonsHeight(geo))
                        .background(.red.opacity(0.0))

                    StateView()
                        .background(.red.opacity(0.6))
                        .frame(height: getStateHeight(geo))
                }
                .background(.red.opacity(0.0))

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
        if !shouldShowTopAlbum(geo) {
            return 0
        }

        return geo.size.width
    }

    // MARK: 标题的高度

    private func getTitleHeight(_ geo: GeometryProxy) -> CGFloat {
        max(0, geo.size.height
            - getAlbumHeight(geo)
            - getErrorsHeight(geo)
            - getSliderHeight(geo)
            - getButtonsHeight(geo)
            - getOperationHeight(geo))
    }

    // MARK: 操作栏的高度

    private func getOperationHeight(_ geo: GeometryProxy) -> CGFloat {
        getButtonsHeight(geo) / 1.3
    }

    // MARK: 错误提示的高度

    private func getErrorsHeight(_ geo: GeometryProxy) -> CGFloat {
        geo.size.height / 10
    }

    // MARK: 进度条的高度

    private func getSliderHeight(_ geo: GeometryProxy) -> CGFloat {
        geo.size.height / 10
    }

    // MARK: 控制按钮的高度

    private func getButtonsHeight(_ geo: GeometryProxy) -> CGFloat {
        geo.size.width / 5
    }
    
    // MARK: 播放状态的高度

    private func getStateHeight(_ geo: GeometryProxy) -> CGFloat {
        20
    }

    private func shouldShowRightAlbum(_ geo: GeometryProxy) -> Bool {
        geo.size.width > 1500
    }

    private func shouldShowTopAlbum(_ geo: GeometryProxy) -> Bool {
        !shouldShowRightAlbum(geo) &&
            geo.size.height
            - getButtonsHeight(geo)
            - getErrorsHeight(geo)
            - getSliderHeight(geo)
            > geo.size.width
    }
}

#Preview("App") {
    AppPreview()
}

#Preview("Layout") {
    LayoutView()
}
