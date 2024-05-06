import OSLog
import SwiftUI

struct Duplicates: View {
    @EnvironmentObject var audioManager: AudioManager

    @State var audios: [Audio] = []
    @State var showDumplicates = false

    var audio: Audio

    init(_ audio: Audio) {
        self.audio = audio
    }

    var body: some View {
        if audio.copies.count > 0 {
            ControlButton(
                title: "\(audios.count)",
                systemImage: getImageName(),
                dynamicSize: false,
                onTap: {
                    showDumplicates.toggle()
                })
                .popover(isPresented: $showDumplicates, content: {
                    List {
                        Section("共 \(audios.count) 个重复文件",content: {
                            ForEach(audios, content: { a in
                                DBRow(a)
                            })
                        })
                    }
                })
                .task {
                    self.audios = audio.copies
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
    }.modelContainer(AppConfig.getContainer())
}
