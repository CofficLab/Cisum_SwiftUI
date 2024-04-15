import SwiftUI
import OSLog

struct BtnPlay: View {
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var appManager: AppManager
    
    @State var isDownloaded = true
    
    var audio: Audio
        
    var body: some View {
        Button {
            audioManager.play(audio, reason: "Play Button")
        } label: {
            Label("播放 「\(audio.title)」", systemImage: getImageName())
                .font(.system(size: 24))
        }
        .onAppear {
            self.isDownloaded = audio.isDownloaded
        }
    }
    
    private func getImageName() -> String {
        return "play.fill"
    }
}

#Preview("Layout") {
    LayoutView()
}
