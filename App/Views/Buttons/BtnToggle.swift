import OSLog
import SwiftUI

struct BtnToggle: View {
    var play: Bool? = true

    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var appManager: AppManager
    @State private var hovered: Bool = false
    
    var title: String { audioManager.isPlaying ? "播放" : "暂停"}
    var systemImage: String {
        if !audioManager.isPlaying {
            "play.fill"
        } else {
            "pause.fill"
        }
    }

    var body: some View {        
        ControlButton(title: title, size: 48, systemImage: systemImage, onTap: {
            do {
                try audioManager.togglePlayPause()
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
