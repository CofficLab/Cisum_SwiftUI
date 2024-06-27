import OSLog
import SwiftUI

struct BtnPlay: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var playMan: PlayMan

    @State var isDownloaded = true

    var asset: PlayAsset
    var autoResize = true
    var player: PlayMan { playMan }

    var body: some View {
        ControlButton(
            title: "播放 「\(asset.fileName)」",
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
