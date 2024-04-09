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
        .disabled(!isDownloaded)
        .onAppear {
            self.isDownloaded = audio.isDownloaded
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("Updated")), perform: {
            notification in
            AppConfig.bgQueue.async {
                let data = notification.userInfo as! [String: [MetadataItemWrapper]]
                let items = data["items"]!
                for item in items {
                    if item.url == audioManager.audio?.url {
                        self.isDownloaded = true
                        return
                    }
                }
            }
        })
    }
    
    private func getImageName() -> String {
        return "play.fill"
    }
}
