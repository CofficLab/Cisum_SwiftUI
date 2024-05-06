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
        if audio.duplicateIds.count > 0 {
            ControlButton(
                title: "显示重复的",
                systemImage: getImageName(),
                dynamicSize: false,
                onTap: {
                    showDumplicates.toggle()
                })
                .popover(isPresented: $showDumplicates, content: {
                    VStack {
                        ForEach(audios) { d in
                            Text("\(d.title)")
                        }
                    }
                })
                .task {
                    self.audios = await audio.getDuplicates(audioManager.db)
                }
        }
    }
    
    private func getImageName() -> String {
        return "doc.text.fill.viewfinder"
    }
}

#Preview {
    RootView {
        ContentView()
    }.modelContainer(AppConfig.getContainer())
}
