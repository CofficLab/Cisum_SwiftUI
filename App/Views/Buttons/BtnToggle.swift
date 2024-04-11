import AVKit
import OSLog
import SwiftUI

struct BtnToggle: View {
    var play: Bool? = true

    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var appManager: AppManager
    @State private var hovered: Bool = false
    @State private var systemImage = "play.fill"

    var audio: Audio? { audioManager.audio }
    var player: AVAudioPlayer { audioManager.player }
    var title: String { player.isPlaying ? "播放" : "暂停" }
    var image: String {
        if audioManager.audio?.isNotDownloaded ?? false {
            "icloud.and.arrow.down"
        } else if !player.isPlaying {
            "play.fill"
        } else {
            "pause.fill"
        }
    }

    var body: some View {
        if let audio = audio, audio.isNotDownloaded {
            AlbumView(audio, forPlaying: false)
        } else {
            ControlButton(title: title, size: 32, systemImage: image, onTap: {
                audioManager.toggle()
            })
        }
        
//        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("Updated")), perform: {
//            notification in
//            AppConfig.bgQueue.async {
//                let data = notification.userInfo as! [String: [MetadataItemWrapper]]
//                let items = data["items"]!
//                for item in items {
//                    if item.url == audioManager.audio?.url {
////                        refresh()
//                        return
//                    }
//                }
//            }
//        })
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
