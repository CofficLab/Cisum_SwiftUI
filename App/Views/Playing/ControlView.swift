import SwiftData
import SwiftUI

struct ControlView: View {
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var appManager: AppManager

    @State var totalHeight: CGFloat = 0
    @State var topAlbumVisible = false
    @State var topAlbumHeight: CGFloat = 0
    @State var titleHeight: CGFloat = 0
    @State var stateViewHeight: CGFloat = 0
    @State var operationHeight: CGFloat = 0
    @State var sliderHeight: CGFloat = 0
    @State var buttonsHeight: CGFloat = 0

    var heightSpace: CGFloat {
        totalHeight
            - self.topAlbumHeight
            - self.titleHeight
            - self.stateViewHeight
            - self.operationHeight
            - self.sliderHeight
            - self.buttonsHeight
    }

    // MARK: 子视图是否展示

    var showOperationView = true
    var showDB: Bool { appManager.showDB }
    var showStateMessage: Bool { appManager.stateMessage.count > 0 }

    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                VStack(spacing: 0) {
                    if shouldShowRightAlbum(geo) == false && geo.size.height > ViewConfig.minHeightToShowAlbum {
                        PlayingAlbum()
                            .frame(maxWidth: .infinity)
                            .background(ViewConfig.background(.yellow))
                            .background(GeometryReader { geo in
                                Color.clear.onAppear {
                                    self.topAlbumHeight = geo.size.height
//                                    printHeight()
                                }
                            })
                    }

                    // MARK: 标题
                    
                    Spacer()
                    if audioManager.showTitleView {
                        TitleView()
                            .frame(maxWidth: .infinity)
                            .background(ViewConfig.background(.red))
                            .background(GeometryReader { geo in
                                Color.clear.onAppear {
                                    self.titleHeight = geo.size.height
//                                    printHeight()
                                }
                            })
                    }
                    Spacer()
                    
                    // MARK: 状态

                    StateView()
//                        .frame(height: getStateHeight(geo))
                        .frame(maxWidth: .infinity)
                        .background(ViewConfig.background(.red))
                        .background(GeometryReader { geo in
                            Color.clear.onAppear {
                                self.titleHeight = geo.size.height
//                                printHeight()
                            }
                        })

                    // MARK: 操作栏

                    if showOperationView {
                        OperationView(geo: geo)
                            .frame(height: getOperationHeight(geo))
                            .background(ViewConfig.background(.white))
                            .background(GeometryReader { geo in
                                Color.clear.onAppear {
                                    self.operationHeight = geo.size.height
//                                    printHeight()
                                }
                            })
                    }

                    // MARK: 进度栏

                    SliderView(geo: geo)
                        .padding()
                        .background(ViewConfig.background(.black))
                        .background(GeometryReader { geo in
                            Color.clear.onAppear {
                                self.sliderHeight = geo.size.height
//                                printHeight()
                            }
                        })

                    // MARK: 控制栏

                    BtnsView()
                        .frame(height: getButtonsHeight(geo))
                        .padding(.bottom, getBottomHeight(geo))
                        .background(ViewConfig.background(.red))
                        .background(GeometryReader { geo in
                            Color.clear.onAppear {
                                self.buttonsHeight = geo.size.height
//                                printHeight()
                            }
                        })
                }

                // MARK: 横向的封面图

                if shouldShowRightAlbum(geo) {
                    // 最大宽度=控制栏的高度+系统标题栏高度
                    HStack {
                        Spacer()
                        PlayingAlbum()
                            .background(ViewConfig.background(.yellow))
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
        .background(GeometryReader { geo in
            Color.clear.onAppear {
                self.totalHeight = geo.size.height
//                printHeight()
            }
        })
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
        return max(0, min(
            geo.size.width / 5,900
        ))
    }

    // MARK: 底部Padding的高度

    private func getBottomHeight(_ geo: GeometryProxy) -> CGFloat {
        if DeviceConfig.noHomeButton && ViewConfig.isNotDesktop && showDB == false {
            return 50
        }

        return 0
    }

    // MARK: 是否显示右侧的封面图

    private func shouldShowRightAlbum(_ geo: GeometryProxy) -> Bool {
        geo.size.width > Device.iPad_mini.width
    }

    private func printHeight() {
        print("共->\(self.totalHeight)\n 封面图->\(self.topAlbumHeight) \n 标题栏->\(self.titleHeight)  \n 状态栏->\(self.stateViewHeight) \n 操作栏->\(self.operationHeight) \n 控制栏->\(self.buttonsHeight) \n 进度栏->\(self.sliderHeight) \n 剩余栏->\(self.heightSpace)")
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
