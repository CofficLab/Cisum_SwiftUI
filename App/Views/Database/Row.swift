import SwiftUI
import OSLog

struct Row: View {
    @EnvironmentObject var audioManager: AudioManager
    
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
        }
        .frame(maxWidth: .infinity)
        .background(.background)
        .contextMenu(ContextMenu(menuItems: {
            BtnPlay(audio: audio)
            BtnDownload(audio: audio)
            Divider()
            BtnDel(audio: audio)
        }))
    }
    
    init(_ audio: Audio) {
        self.audio = audio
//        os_log("\(Logger.isMain)🚩 🖥️ 初始化 \(audio.title)")
    }
    
    private func shouldHighlight(_ audio: Audio) -> Bool {
        audioManager.audio == audio
    }
}
