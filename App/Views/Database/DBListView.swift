import SwiftUI

struct DBListView: View {
    @EnvironmentObject var audioManager: AudioManager

    var count: Int { audioManager.list.count }
    var audios: [Audio] { audioManager.list.all }

    var body: some View {
        list
    }

    var list: some View {
        List(audios) { audio in
            Cell(audio)
                .contextMenu(ContextMenu(menuItems: {
                    BtnPlay(audio: audio)
                    BtnDownload(audio: audio)
                    Divider()
                    BtnDel(audio: audio)
                }))
        }
    }

    var lazy: some View {
        ScrollView {
            LazyVStack {
                ForEach(0...max(0, count-1), id: \.self) { i in
                    if let audio = audioManager.list.get(i) {
                        Cell(audio)
                            .contextMenu(ContextMenu(menuItems: {
                                BtnPlay(audio: audio)
                                BtnDownload(audio: audio)
                                Divider()
                                BtnDel(audio: audio)
                            }))
                    }
                }
            }
        }.background(.background)
    }
}

#Preview {
    RootView {
        ContentView()
    }
}

#Preview {
    RootView {
        DBListView()
    }
}
