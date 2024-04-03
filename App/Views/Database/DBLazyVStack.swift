import SwiftUI
import SwiftData

struct DBLazyVStack: View {
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

    var lazy: some View {
        VStack {
            ScrollView {
                LazyVStack {
                    ForEach(audios, id: \.self) { audio in
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
                .padding(.vertical)
            }
            .background(.background)
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
