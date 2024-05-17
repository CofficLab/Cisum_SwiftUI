import SwiftData
import SwiftUI

struct ControlView: View {
    @EnvironmentObject var appManager: AppManager

    @State var showHeroView = false
    @State var showSliderView = false
    @State var showBtnsView = false
    @State var showOperationView = false
    @State var showStateView = false

    // MARK: 子视图是否展示

    var showDB: Bool { appManager.showDB }
    var showStateMessage: Bool { appManager.stateMessage.count > 0 }

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
                        StateView()
                            //                        .frame(height: getStateHeight(geo))
                            .frame(maxWidth: .infinity)
                            .background(AppConfig.background(.red))
                    }

                    // MARK: 操作栏

                    if showOperationView {
                        if showOperationView {
                            OperationView(geo: geo)
                                .frame(height: getOperationHeight(geo))
                                .background(AppConfig.background(.white))
                        }
                    }

                    // MARK: 进度栏

                    if showSliderView {
                        SliderView(geo: geo)
                            .padding()
                            .background(AppConfig.background(.black))
                    }

                    // MARK: 控制栏

                    if showBtnsView {
                        BtnsView()
                            .frame(height: getButtonsHeight(geo))
                            .padding(.bottom, getBottomHeight(geo))
                            .background(AppConfig.background(.red))
                    }
                }

                // MARK: 横向的封面图

                if shouldShowRightAlbum(geo) {
                    // 最大宽度=控制栏的高度+系统标题栏高度
                    HStack {
                        Spacer()
                        PlayingAlbum()
                            .background(AppConfig.background(.yellow))
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
        .foregroundStyle(.white)
        .ignoresSafeArea()
        .frame(minHeight: AppConfig.controlViewMinHeight)
        .onAppear() {
            showHeroView = true
            showSliderView = true
            showBtnsView = true
            showOperationView = true
            showStateView = true
        }
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

        return getButtonsHeight(geo) * 0.6
    }

    // MARK: 控制按钮的高度

    private func getButtonsHeight(_ geo: GeometryProxy) -> CGFloat {
        min(geo.size.width / 5, 900, geo.size.height / 4)
    }

    // MARK: 底部Padding的高度

    private func getBottomHeight(_ geo: GeometryProxy) -> CGFloat {
        if DeviceConfig.hasHomeIndicator() && AppConfig.isNotDesktop && showDB == false {
            return 50
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
