import SwiftUI
import OSLog

struct Cell: View {
    @EnvironmentObject var audioManager: AudioManager
    
    static var count = 0
    
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
        }
    }
    
    init(_ audio: Audio) {
        Self.count += 1
        self.audio = audio
        os_log("\(Logger.isMain)🚩 初始化 \(audio.title) -> \(Self.count)")
    }
    
    private func shouldHighlight(_ audio: Audio) -> Bool {
        audioManager.audio == audio
    }
}
