import SwiftData
import SwiftUI

struct VideoControl: View {
    @EnvironmentObject var appManager: AppProvider
    @EnvironmentObject var messageManager: MessageProvider
    @EnvironmentObject var playMan: PlayMan

    @State var showHeroView = true
    @State var showBtnsView = true
    @State var showOperationView = false
    @State var showStateView = true

    // MARK: 子视图是否展示

    var showDB: Bool { appManager.showDB }
    var showStateMessage: Bool { messageManager.stateMessage.count > 0 }
    var showSliderView: Bool { playMan.isAudioWorker }

    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                VStack(spacing: 0) {
                    // MARK: 封面图和标题

                    if showHeroView {
                        HeroView()
                            .frame(maxWidth: .infinity)
                            .frame(maxHeight: .infinity)
                    }

                    // MARK: 状态

                    if showStateView {
//                        StateView()
                            //                        .frame(height: getStateHeight(geo))
//                            .frame(maxWidth: .infinity)
//                            .background(Config.background(.red))
                    }

                    // MARK: 操作栏

                    if showOperationView {
                        OperationView(geo: geo)
                            .frame(height: getOperationHeight(geo))
                            .background(Config.background(.white))
                    }

                    // MARK: 进度栏

                    if showSliderView {
                        SliderView(geo: geo)
                            .padding()
                            .background(Config.background(.black))
                    }

                    // MARK: 控制栏

                    if showBtnsView {
                        VideoBtns()
                            .frame(height: getButtonsHeight(geo))
                            .padding(.bottom, getBottomHeight(geo))
                            .background(Config.background(.red))
                    }
                }

                // MARK: 横向的封面图

                if shouldShowRightAlbum(geo) {
                    // 最大宽度=控制栏的高度+系统标题栏高度
                    HStack {
                        Spacer()
                        PlayingAlbum()
                            .background(Config.background(.yellow))
                    }
                    .frame(maxWidth: geo.size.height * 1.3)
                    .onAppear {
                        appManager.rightAlbumVisible = true
                    }
                    .onDisappear {
                        appManager.rightAlbumVisible = false
                    }
                }
            }
            .padding(.bottom, 0)
            .padding(.horizontal, 0)
            .frame(maxHeight: .infinity)
        }
//        .ignoresSafeArea(edges: appManager.showDB || Config.isNotDesktop ? .horizontal : .all)
        .frame(minHeight: Config.controlViewMinHeight)
        .onAppear() {
            showHeroView = true
            showBtnsView = true
            showStateView = true
        }
    }

    // MARK: 状态栏的高度

    private func getStateHeight(_ geo: GeometryProxy) -> CGFloat {
        if geo.size.height <= Config.minHeight {
            return 24
        }

        if geo.size.height <= Config.minWidth + 100 {
            return 36
        }

        return 48
    }

    // MARK: 操作栏的高度

    private func getOperationHeight(_ geo: GeometryProxy) -> CGFloat {
        if showOperationView == false {
            return 0
        }

        return getButtonsHeight(geo) * 0.6
    }

    // MARK: 控制按钮的高度

    private func getButtonsHeight(_ geo: GeometryProxy) -> CGFloat {
        min(geo.size.width / 5, 900, geo.size.height / 4)
    }

    // MARK: 底部Padding的高度

    private func getBottomHeight(_ geo: GeometryProxy) -> CGFloat {
        if Config.hasHomeIndicator() && Config.isNotDesktop && showDB == false {
            return 0
        }

        return 0
    }

    // MARK: 是否显示右侧的封面图

    private func shouldShowRightAlbum(_ geo: GeometryProxy) -> Bool {
        geo.size.width > Device.iPad_mini.width
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}

#Preview("iMac") {
    LayoutView(device: .iMac)
}

#Preview("iPhone 15") {
    LayoutView(device: .iPhone_15)
}

#Preview("iPad") {
    LayoutView(device: .iPad_mini)
}

#Preview("Layout") {
    LayoutView()
}

#Preview("Layout-500") {
    LayoutView(width: 500)
}

#Preview("Layout-1500") {
    LayoutView(width: 1500)
}
