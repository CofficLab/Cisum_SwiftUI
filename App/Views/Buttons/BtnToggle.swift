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
    var player: SmartPlayer { audioManager.player }
    var title: String { player.isPlaying ? "播放" : "暂停" }
    var autoResize = false

    var image: String {
        if !player.isPlaying {
            "play.fill"
        } else {
            "pause.fill"
        }
    }

    var body: some View {
        ControlButton(title: title, image: image, dynamicSize: autoResize, onTap: {
            audioManager.toggle()
        })
    }
}

#Preview("APP") {
    RootView(content: {
        ContentView()
    })
    .modelContainer(AppConfig.getContainer)
}

#Preview {
    RootView(content: {
        Centered {
            BtnToggle()
        }

        ControlView()
    })
}
