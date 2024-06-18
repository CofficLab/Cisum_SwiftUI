import OSLog
import SwiftUI

struct BtnPlay: View {
    @EnvironmentObject var audioManager: PlayManager
    @EnvironmentObject var appManager: AppManager

    @State var isDownloaded = true

    var audio: Audio
    var autoResize = true

    var body: some View {
        ControlButton(
            title: "播放 「\(audio.title)」",
            image: getImageName(),
            dynamicSize: autoResize,
            onTap: {
                audioManager.play(audio, reason: "Play Button")
            })
    }

    private func getImageName() -> String {
        return "play.fill"
    }
}

#Preview("Layout") {
    LayoutView()
}
