import OSLog
import SwiftUI
import AVKit

struct BtnToggle: View {
    var play: Bool? = true

    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var appManager: AppManager
    @State private var hovered: Bool = false
    @State private var systemImage = "play.fill"
    
    var player: AVAudioPlayer { audioManager.player }
    var title: String { player.isPlaying ? "播放" : "暂停"}
    var isPlaying: Bool { audioManager.isPlaying }

    var body: some View {        
        ControlButton(title: title, size: 32, systemImage: systemImage, onTap: {
            audioManager.toggle()
            refresh()
        })
        .onAppear {
            refresh()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("Updated")), perform: {
            notification in
               AppConfig.bgQueue.async {
                   let data = notification.userInfo as! [String: [MetadataItemWrapper]]
                   let items = data["items"]!
                   for item in items {
                       if item.url == audioManager.audio?.url {
                           refresh()
                           return
                       }
                   }
               }
        })
    }
    
    func refresh() {
        if audioManager.audio?.isNotDownloaded ?? false {
            self.systemImage = "icloud.and.arrow.down"
        } else if !isPlaying {
            self.systemImage = "play.fill"
        } else {
            self.systemImage = "pause.fill"
        }
    }
}

#Preview {
    RootView(content: {
        ContentView()
    })
}

#Preview {
    RootView(content: {
        Centered {
            BtnToggle()
        }

        ControlView()
    })
}
