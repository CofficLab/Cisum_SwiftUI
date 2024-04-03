import SwiftUI
import OSLog

struct BtnPlay: View {
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var appManager: AppManager
    
    var audio: Audio
        
    var body: some View {
        Button {
            play()
        } label: {
            Label("播放 「\(audio.title)」", systemImage: getImageName())
                .font(.system(size: 24))
        }.disabled(audio.isNotDownloaded)
    }
    
    func play() {
        if audio.isDownloading {
            return appManager.setFlashMessage("正在从 iCloud 下载")
        }
        
        audioManager.play(url: audio.url)
    }
    
    private func getImageName() -> String {
        return "play.fill"
    }
}
