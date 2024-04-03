import SwiftUI
import OSLog

struct Cell: View {
    @EnvironmentObject var audioManager: AudioManager
    
    var audio: Audio
    
    var downloadings: [Audio] { audioManager.downloadingItems }
    
    var body: some View {
        HStack {
            AlbumView(audio: audio, withBackground: true, rotate: false)
                .frame(width: 24, height: 24)
                .environmentObject(audioManager)
            Text(audio.title)
            Spacer()
            if let d = downloadings.first(where: { $0.id == audio.id }) {
                Text("\(String(format: "%.0f", d.downloadingPercent))%").font(.footnote)
            }
        }.contextMenu(ContextMenu(menuItems: {
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
