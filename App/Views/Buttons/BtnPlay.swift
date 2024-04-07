import SwiftUI
import OSLog

struct BtnPlay: View {
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var appManager: AppManager
    
    var audio: Audio
        
    var body: some View {
        Button {
            audioManager.play(audio, reason: "Play Button")
        } label: {
            Label("播放 「\(audio.title)」", systemImage: getImageName())
                .font(.system(size: 24))
        }.disabled(audio.isNotDownloaded)
    }
    
    private func getImageName() -> String {
        return "play.fill"
    }
}
