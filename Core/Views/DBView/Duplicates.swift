import OSLog
import SwiftUI
import SwiftData

struct Duplicates: View {
    @State var showDumplicates = false
    
    @Query var audios: [Audio]

    var audio: Audio
    var duplicates: [Audio] = []

    init(_ audio: Audio) {
        self.audio = audio
    }

    var body: some View {
        ZStack {
            if duplicates.count > 0 {
                ControlButton(
                    title: "\(duplicates.count)",
                    image: getImageName(),
                    dynamicSize: false,
                    onTap: {
                        showDumplicates.toggle()
                    })
                    .popover(isPresented: $showDumplicates, content: {
                        List {
//                            Section("共 \(duplicates.count) 个重复文件",content: {
//                                ForEach(duplicates, content: { a in
//                                    AudioTile(a.toPlayAsset())
//                                })
//                            })
                        }
                    })
            }
        }
    }

    private func getImageName() -> String {
        return "doc.circle"
    }
}

#Preview {
    RootView {
        ContentView()
    }.modelContainer(Config.getContainer)
}
