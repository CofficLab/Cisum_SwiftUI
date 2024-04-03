import SwiftUI

struct DBListView: View {
    @EnvironmentObject var audioManager: AudioManager

    var total: Int { audioManager.total }
    var maxIndex: Int { max(0, total - 1) }
    var audios: [Audio] { audioManager.list.all }
    var downloaded: [Audio] { audioManager.list.downloaded }
    var description: String {
        if downloaded.count == total {
            return "共 \(total)"
        }

        return "\(downloaded.count)/\(total) 已下载 "
    }

    var body: some View {
        lazy
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

    var lazyList: some View {
        List {
            ForEach(0...maxIndex, id: \.self) { i in
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
    }

    var lazy: some View {
        VStack {
            ScrollView {
                LazyVStack {
                    ForEach(0...maxIndex, id: \.self) { i in
                        if let audio = audioManager.list.get(i) {
                            Cell(audio)
                                .contextMenu(ContextMenu(menuItems: {
                                    BtnPlay(audio: audio)
                                    BtnDownload(audio: audio)
                                    Divider()
                                    BtnDel(audio: audio)
                                })).padding(.horizontal)
                            Divider()
                        }
                    }
                }
                .padding(.vertical)
            }
            .background(.background)

            if total > 0 {
                VStack {
                    Spacer()
                    Text(description)
                        .font(.footnote)
                        .foregroundStyle(.white)
                    Spacer()
                }.frame(height: 10)
            }
        }
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
