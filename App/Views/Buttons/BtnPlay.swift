import OSLog
import SwiftUI

struct BtnPlay: View {
    @EnvironmentObject var audioManager: PlayManager
    @EnvironmentObject var appManager: AppManager

    @State var isDownloaded = true

    var asset: PlayAsset
    var autoResize = true
    var player: PlayMan { audioManager.playMan }

    var body: some View {
        ControlButton(
            title: "播放 「\(asset.title)」",
            image: getImageName(),
            dynamicSize: autoResize,
            onTap: {
                player.play(asset, reason: "Play Button")
            })
    }

    private func getImageName() -> String {
        return "play.fill"
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}

#Preview("Layout") {
    LayoutView()
}
