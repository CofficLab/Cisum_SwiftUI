import SwiftUI

struct ControlView: View {
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var appManager: AppManager

    var body: some View {
        #if os(macOS)
            GeometryReader { geo in
                HStack(spacing: 0) {
                    VStack(spacing: 0) {
                        Spacer()
                        TitleView()
                        BtnsView().frame(height: 90)
                        SliderView().frame(height: 30).padding(.bottom, 10)
                        // StateView()
                    }

                    if geo.size.width > 500 {
                        // 最大宽度=控制栏的高度+系统标题栏高度
                        HStack {
                            Spacer()
                            PlayingAlbum()
                        }.frame(maxWidth:geo.size.height*1.3)
                    }
                }
                .padding(.bottom, 0)
                .padding(.horizontal, 0)
            }
            .foregroundStyle(.white)
            .ignoresSafeArea()
        #else
            VStack {
                if !appManager.showDB {
                    PlayingAlbum()
                }
                TitleView().padding(.vertical, 20)
                SliderView().padding(.vertical, 20)
                BtnsView().padding(.vertical, 30)
            }.foregroundStyle(.white)
        #endif
    }
}

#Preview("APP") {
    RootView {
        ContentView()
    }
}

#Preview("响应式") {
    RootView(content: {
        HStack {
            Spacer()
            VStack(content: {
                Spacer()

                HStack(content: {
                    ControlView()
                }).frame(width: 350, height: AppConfig.controlViewHeight + 100).border(.red)

                HStack(content: {
                    ControlView()
                }).frame(width: 350, height: AppConfig.controlViewHeight).border(.red)

                HStack(content: {
                    ControlView()
                }).frame(width: 400, height: AppConfig.controlViewHeight).border(.red)

                HStack(content: {
                    ControlView()
                }).frame(width: 500, height: AppConfig.controlViewHeight).border(.red)

                HStack(content: {
                    ControlView()
                }).frame(width: 600, height: AppConfig.controlViewHeight).border(.red)

                HStack(content: {
                    ControlView()
                }).frame(width: 700, height: AppConfig.controlViewHeight).border(.red)

                HStack(content: {
                    ControlView()
                }).frame(width: 800, height: AppConfig.controlViewHeight).border(.red)
                Spacer()
            })
            Spacer()
        }
    })
}
