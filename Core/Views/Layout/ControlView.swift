import SwiftData
import SwiftUI
import OSLog
import MagicCore

struct ControlView: View, SuperLog {
    @EnvironmentObject var appManager: AppProvider
    @EnvironmentObject var message: StateProvider
    @EnvironmentObject var playMan: PlayManController
    @EnvironmentObject var p: PluginProvider

    @State var showHeroView = true
    @State var showBtnsView = true
    @State var showOperationView = false
    @State var showStateView = true

    // MARK: 子视图是否展示

    var showDB: Bool { appManager.showDB }
    var showStateMessage: Bool { message.stateMessage.count > 0 }
    var showSliderView: Bool { true }

    var body: some View {
        os_log("\(self.t)开始渲染")
        return GeometryReader { geo in
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
                        VStack(spacing: 10) {
                            StateView()
                            
                            ForEach(p.plugins, id: \.id) { plugin in
                                plugin.addStateView(currentGroup: p.current)
                            }
                        }
                        .frame(height: getStateHeight(geo))
                        .frame(maxWidth: .infinity)
                    }

                    // MARK: 操作栏

                    if showOperationView {
                        OperationView(geo: geo)
                            .frame(height: getOperationHeight(geo))
                            .background(Config.background(.white))
                    }

                    // MARK: 进度栏

                    if showSliderView {
                        playMan.playMan.makeProgressView()
                            .padding()
                    }

                    // MARK: 控制栏

                    if showBtnsView {
                        ControlBtns()
                            .frame(height: getButtonsHeight(geo))
                            .frame(maxWidth: .infinity)
                            .padding(.bottom, getBottomHeight(geo))
                            .background(Config.background(.red))
                    }
                }

                // MARK: 横向的封面图

                if shouldShowRightAlbum(geo) {
                    // 最大宽度=控制栏的高度+系统标题栏高度
                    HStack {
                        Spacer(minLength: 0)
                        playMan.playMan.makeHeroView()
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
        .ignoresSafeArea(edges: Config.isDesktop ? .horizontal : .all)
        .frame(minHeight: Config.controlViewMinHeight)
        .onAppear {
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
        geo.size.width > MagicDevice.iPad_mini.width
    }
}

#Preview("App - Large") {
    AppPreview()
        .frame(width: 600, height: 1000)
}

#Preview("App - Small") {
    AppPreview()
        .frame(width: 500, height: 600)
}

#if os(iOS)
#Preview("iPhone") {
    AppPreview()
}
#endif
