import SwiftUI
import OSLog

struct BtnPlay: View {
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var appManager: AppManager
    
    var audio: AudioModel
        
    var body: some View {
        Button {
            play()
        } label: {
            Label("播放 「\(audio.title)」", systemImage: getImageName())
                .font(.system(size: 24))
        }
    }
    
    func play() {
        if audio.isEmpty() {
            do {
                let message = try audioManager.next()
                os_log("BtnPlay::\(message)")
            } catch let e {
                appManager.setFlashMessage(e.localizedDescription)
            }
            
            return
        }
        
        if audio.getiCloudState() == .Downloading {
            return appManager.setFlashMessage("正在从 iCloud 下载")
        }
        
        audioManager.play(audio)
    }
    
    private func getImageName() -> String {
        return "play.fill"
    }
}
