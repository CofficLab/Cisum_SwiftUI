import AVKit
import OSLog
import SwiftUI

struct BtnToggle: View {
    var play: Bool? = true

    @EnvironmentObject var audioManager: PlayManager
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var playMan: PlayMan
    
    @State private var hovered: Bool = false
    @State private var systemImage = "play.fill"

    var title: String { playMan.isPlaying ? "播放" : "暂停" }
    var autoResize = false

    var image: String {
        if !playMan.isPlaying {
            "play.fill"
        } else {
            "pause.fill"
        }
    }

    var body: some View {
        ControlButton(title: title, image: image, dynamicSize: autoResize, onTap: {
            playMan.toggle()
        })
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}
