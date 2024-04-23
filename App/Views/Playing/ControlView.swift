import SwiftData
import SwiftUI

struct ControlView: View {
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var appManager: AppManager

    @Query var tasks: [CopyTask]

    @State var topAlbumVisible = false
    @State var topAlbumHeight: CGFloat = 0

    var taskCount: Int { tasks.count }

    // MARK: 子视图是否展示

    var showOperationView = true
    var showDB: Bool { appManager.showDB }
    var showStateMessage: Bool { appManager.stateMessage.count > 0 }
    var showCopyMessage: Bool { tasks.count > 0 }

    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                VStack(spacing: 0) {
                    PlayingAlbum()
                        .frame(height: getAlbumHeight(geo))
                    // .background(AppConfig.makeBackground(.red))

                    // MARK: 标题

                    if audioManager.showTitleView {
                        TitleView(geo: geo)
                            .frame(height: getTitleHeight(geo))
                            .frame(maxHeight: .infinity)
                            .background(AppConfig.makeBackground(.red))
                    }

                    StateView()
                        .frame(height: getStateHeight(geo))
                        .frame(maxHeight: .infinity)
                    // .background(AppConfig.makeBackground(.red))

                    if showOperationView {
                        OperationView(geo: geo)
                            .frame(height: getOperationHeight(geo))
                    }

                    Spacer()

                    SliderView(geo: geo)
                        .frame(height: getSliderHeight(geo))
                        .frame(maxHeight: .infinity)
                        .background(AppConfig.makeBackground(.red))

                    BtnsView()
                        .frame(height: getButtonsHeight(geo))
                        .padding(.bottom, getBottomHeight(geo))
                }

                // MARK: 横向的封面图

                if shouldShowRightAlbum(geo) {
                    // 最大宽度=控制栏的高度+系统标题栏高度
                    HStack {
                        Spacer()
                        PlayingAlbum()
                        // .background(AppConfig.makeBackground(.yellow))
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

    // MARK: 状态栏的高度

    private func getStateHeight(_ geo: GeometryProxy) -> CGFloat {
        if geo.size.height <= AppConfig.minHeight {
            return 24
        }

        if geo.size.height <= AppConfig.minWidth + 100 {
            return 36
        }

        return 48
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
        return 80
    }

    // MARK: 控制按钮的高度

    private func getButtonsHeight(_ geo: GeometryProxy) -> CGFloat {
        if topAlbumVisible {
            return max(0, min(geo.size.width / 5, geo.size.height
                    - getTitleHeight(geo)
                    - topAlbumHeight
                    - getSliderHeight(geo)))
        }

        return max(0, min(
            geo.size.width / 5,
            geo.size.height / 2,
            geo.size.height
                - getTitleHeight(geo)
                - getSliderHeight(geo)
        ))
    }

    // MARK: 底部Padding的高度

    private func getBottomHeight(_ geo: GeometryProxy) -> CGFloat {
        if UIConfig.isNotDesktop && showDB == false {
            return 50
        }

        return 0
    }

    // MARK: 是否显示右侧的封面图

    private func shouldShowRightAlbum(_ geo: GeometryProxy) -> Bool {
        geo.size.width > Device.iPad_mini.width
    }

    private func shouldShowTopAlbum(_ geo: GeometryProxy) -> Bool {
        !shouldShowRightAlbum(geo) &&
            geo.size.height
            - getTitleHeight(geo)
            - getOperationHeight(geo)
            - getSliderHeight(geo)
            - getButtonsHeight(geo)
            - getBottomHeight(geo)
            - getStateHeight(geo)
            > geo.size.width
    }
}

#Preview("App") {
    AppPreview()
}

#Preview("iMac") {
    LayoutView(device: .iMac)
}

#Preview("iPad") {
    LayoutView(device: .iPad_mini)
}

#Preview("Layout") {
    LayoutView()
}

#Preview("Layout-500") {
    LayoutView(width: 500)
        .frame(width: AppConfig.minWidth + 500)
}

#Preview("Layout-1500") {
    LayoutView(width: 1500)
        .frame(width: AppConfig.minWidth + 1500)
}
