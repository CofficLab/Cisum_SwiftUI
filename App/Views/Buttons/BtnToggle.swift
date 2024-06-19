import AVKit
import OSLog
import SwiftUI

struct BtnToggle: View {
    var play: Bool? = true

    @EnvironmentObject var audioManager: PlayManager
    @EnvironmentObject var appManager: AppManager
    @State private var hovered: Bool = false
    @State private var systemImage = "play.fill"

    var player: PlayMan { audioManager.playMan }
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
            player.toggle()
        })
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}
