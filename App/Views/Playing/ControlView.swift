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
                        Spacer()
                        TitleView()
                        ButtonsView()
                        SliderView()
                        //StateView()
                        Spacer()
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
        ContentView(play: false)
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
                }).frame(width: 350, height: AppManager.controlViewHeight + 100).border(.red)

                HStack(content: {
                    ControlView()
                }).frame(width: 350, height: AppManager.controlViewHeight).border(.red)

                HStack(content: {
                    ControlView()
                }).frame(width: 400, height: AppManager.controlViewHeight).border(.red)

                HStack(content: {
                    ControlView()
                }).frame(width: 500, height: AppManager.controlViewHeight).border(.red)

                HStack(content: {
                    ControlView()
                }).frame(width: 600, height: AppManager.controlViewHeight).border(.red)

                HStack(content: {
                    ControlView()
                }).frame(width: 700, height: AppManager.controlViewHeight).border(.red)

                HStack(content: {
                    ControlView()
                }).frame(width: 800, height: AppManager.controlViewHeight).border(.red)
                Spacer()
            })
            Spacer()
        }
    })
}
