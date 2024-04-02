import SwiftUI
import OSLog

struct DBFirstCol: View {
    @EnvironmentObject var audioManager: AudioManager
    
    @State var audio: Audio
    
    var downloadings: [Audio] { audioManager.downloadingItems }
    
    var body: some View {
        HStack {
            AlbumView(audio: audio, withBackground: true, rotate: false)
                .frame(width: 24, height: 24)
                .environmentObject(audioManager)
            Text(audio.title)
                .foregroundStyle(shouldHighlight(audio) ? .blue : .primary)
            Spacer()
            if let d = downloadings.first(where: { $0.id == audio.id }) {
                Text("\(String(format: "%.0f", d.downloadingPercent))%").font(.footnote)
            }
        }
    }
    
    private func shouldHighlight(_ audio: Audio) -> Bool {
        audioManager.audio == audio
    }
}
