import OSLog
import SwiftUI

struct BtnPlay: View {
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var appManager: AppManager

    @State var isDownloaded = true

    var audio: Audio
    var dynamicSize = true

    var body: some View {
        ControlButton(
            title: "播放 「\(audio.title)」",
            systemImage: getImageName(),
            dynamicSize: dynamicSize,
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
