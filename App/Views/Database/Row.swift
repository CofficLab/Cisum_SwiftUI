import SwiftUI
import OSLog

struct Row: View {
    @EnvironmentObject var audioManager: AudioManager
    
    @State var hovered = false
    @State var audio: Audio
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                HStack {
                    //Text("[\(audio.order)]")
                    AlbumView(audio).frame(width: 24, height: 24)
                    Text(audio.title)
                    Spacer()
                }
                .padding(.leading, 20)
                .padding(.vertical, 1)
                Divider()
            }
        }
        .background(getBackground())
        .onHover(perform: { hovered = $0 })
        .onTapGesture(count: 2, perform: {
            audioManager.play(audio, reason: "Double Tap")
        })
        .contextMenu(menuItems: {
            BtnPlay(audio: audio)
            BtnDownload(audio: audio)
            BtnShowInFinder(url: audio.url)
            Divider()
            BtnTrash(audio: audio)
        })
    }
    
    init(_ audio: Audio) {
        self.audio = audio
        //os_log("\(Logger.isMain)🚩 🖥️ 初始化 \(audio.title)")
    }
    
    private func getBackground() -> Color {
        if let current = audioManager.audio, current.id == audio.id {
            return AppConfig.getBackground.opacity(0.5)
        }
        
        return hovered ? AppConfig.getBackground.opacity(0.9) : AppConfig.getBackground
    }
}

#Preview {
    RootView {
        ContentView()
    }.modelContainer(AppConfig.getContainer())
}
