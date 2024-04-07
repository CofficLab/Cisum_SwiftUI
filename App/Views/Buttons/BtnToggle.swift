import OSLog
import SwiftUI
import AVKit

struct BtnToggle: View {
    var play: Bool? = true

    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var appManager: AppManager
    @State private var hovered: Bool = false
    
    var player: AVAudioPlayer { audioManager.player }
    var title: String { player.isPlaying ? "播放" : "暂停"}
    var isPlaying: Bool { player.isPlaying }
    
    var systemImage: String {
        if !isPlaying {
            "play.fill"
        } else {
            "pause.fill"
        }
    }

    var body: some View {        
        ControlButton(title: title, size: 48, systemImage: systemImage, onTap: {
            do {
                try audioManager.toggle()
            } catch let e {
                appManager.setFlashMessage(e.localizedDescription)
            }
        })
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
