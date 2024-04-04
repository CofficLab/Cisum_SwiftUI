import SwiftUI
import OSLog

struct Row: View {
    @EnvironmentObject var audioManager: AudioManager
    
    @State var hovered = false
    
    var audio: Audio
    
    var body: some View {
        ZStack {
            HStack {
                AlbumView(audio: audio, withBackground: true, rotate: false)
                    .frame(width: 24, height: 24)
                    .environmentObject(audioManager)
                Text(audio.title)
                Spacer()
                if audio.isDownloading {
                    Text("\(String(format: "%.0f", audio.downloadingPercent))%").font(.footnote)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 4)
        }
        .background(getBackground())
        .onHover(perform: { hovered = $0 })
        .contextMenu(menuItems: {
            BtnPlay(audio: audio)
            BtnDownload(audio: audio)
            BtnShowInFinder(url: audio.url)
            Divider()
            BtnDel(audio: audio)
        })
    }
    
    init(_ audio: Audio) {
        self.audio = audio
//        os_log("\(Logger.isMain)🚩 🖥️ 初始化 \(audio.title)")
    }
    
    private func getBackground() -> Color {
        if audioManager.audio == audio {
            return Color.blue.opacity(0.3)
        }
        
        return hovered ? Color(.controlBackgroundColor).opacity(0.9) : Color(.controlBackgroundColor)
    }
    
    private func shouldHighlight(_ audio: Audio) -> Bool {
        audioManager.audio == audio
    }
}

#Preview {
    RootView {
        ContentView()
    }
}
