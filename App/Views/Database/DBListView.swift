import SwiftUI
import SwiftData

struct DBListView: View {
    @EnvironmentObject var audioManager: AudioManager
    @Environment(\.modelContext) private var modelContext
    @Query private var audios: [Audio]

    var body: some View {
        lazy.toolbar(content: {
            Button("添加", action: {
                addItem()
            })
        })
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
            ForEach(0...12, id: \.self) { i in
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
                    ForEach(0...12, id: \.self) { i in
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

//            if total > 0 {
//                VStack {
//                    Spacer()
//                    Text(description)
//                        .font(.footnote)
//                        .foregroundStyle(.white)
//                    Spacer()
//                }.frame(height: 10)
//            }
        }
    }
    
    private func addItem() {
        withAnimation {
            let newItem = Audio(AppConfig.appDir)
            modelContext.insert(newItem)
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
