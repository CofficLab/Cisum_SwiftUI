import SwiftUI

struct ControlView: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var dbManager: DBManager

    var playNow: Bool? = false

    var body: some View {
        #if os(macOS)
            GeometryReader { geo in
                HStack {
                    VStack {
                        TitleView()
                        Spacer()
                        ButtonsView().frame(height: 60)
                        SliderView().frame(height: 30)
                        // StateView()
                    }

                    if geo.size.width > 500 {
                        AlbumView(audio: $audioManager.audio)
                    }
                }
                .padding(.bottom, 10)
                .padding(.horizontal, 10)
            }.foregroundStyle(.white)
        #else
            VStack {
                TitleView().padding(.vertical, 20)
                AlbumView(audio: $audioManager.audio)
                    .opacity(dbManager.audios.isEmpty ? 0 : 1)
                if dbManager.isEmpty {
                    DBEmptyView().padding(.vertical, 40)
                }
                SliderView().padding(.vertical, 20)
                ButtonsView().padding(.vertical, 30)
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
