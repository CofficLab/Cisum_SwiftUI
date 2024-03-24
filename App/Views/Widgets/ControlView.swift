import SwiftUI

struct ControlView: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var databaseManager: DBManager
    @EnvironmentObject var playListManager: PlayListManager

    @State private var selectedList: String = ""
    @State private var popoverDisplay: Bool = false

    var playNow: Bool? = false

    var body: some View {
        #if os(macOS)
            GeometryReader { geo in
                HStack {
                    VStack {
                        Spacer()
                        title
                        buttons
                        slider
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
                title
                    .padding(.vertical, 20)

                AlbumView(audio: $audioManager.audio)
                    .opacity(databaseManager.audios.isEmpty ? 0 : 1)

                if databaseManager.isEmpty {
                    EmptyDatabaseView()
                        .padding(.vertical, 40)
                }

                SliderView().padding(.vertical, 20)
                buttons.padding(.vertical, 30)
            }.foregroundStyle(.white)
        #endif
    }

    private var title: some View {
        VStack {
            if databaseManager.isEmpty {
                Label("无可播放的文件", systemImage: "info.circle")
                    .foregroundStyle(.white)
                    .opacity(databaseManager.audios.isEmpty ? 1 : 0)
            } else {
                Text(audioManager.audio.title).foregroundStyle(.white)
                    .font(.title2)
                    .opacity(databaseManager.audios.isEmpty ? 0 : 1)

                Text(audioManager.audio.artist).foregroundStyle(.white).opacity(databaseManager.audios.isEmpty ? 0 : 1)
            }
        }
    }

    private var slider: some View {
        SliderView()
    }

    private var playList: some View {
        HStack {
            Text(playListManager.current.title)
                .font(.title2)
                .foregroundStyle(.white)
                .onTapGesture {
                    popoverDisplay.toggle()
                }
        }
        .popover(isPresented: $popoverDisplay, arrowEdge: .bottom) {
            List {
                ForEach(playListManager.items) { item in
                    Text(item.title)
                }
            }
        }
    }

    private var buttons: some View {
        HStack(spacing: 0, content: {
            ButtonToggleDatabase()
            ButtonPrev()
            ButtonPlayPause()
            ButtonNext()
            ButtonPlayMode()
        })
        .foregroundStyle(.white)
        .labelStyle(.iconOnly)
        #if os(iOS)
            .scaleEffect(1.2)
        #endif
    }
}

#Preview("HomeView") {
    RootView {
        HomeView(play: false)
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
