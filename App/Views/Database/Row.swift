import SwiftUI
import OSLog

struct Row: View {
    @EnvironmentObject var audioManager: AudioManager
    
    @State var hovered = false
    
    var audio: Audio
    var current: Audio? { audioManager.audio }
    var background: Color {
        if current?.url == audio.url {
            return AppConfig.getBackground.opacity(0.5)
        }
        
        return hovered ? AppConfig.getBackground.opacity(0.9) : AppConfig.getBackground
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
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
        .background(background)
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
}

#Preview {
    RootView {
        ContentView()
    }.modelContainer(AppConfig.getContainer())
}
