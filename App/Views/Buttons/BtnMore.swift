import OSLog
import SwiftUI

struct BtnMore: View {
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
            },
            menus: AnyView(VStack{
                BtnPlay(asset:asset, autoResize: false)
                Divider()
                BtnDownload(asset: asset)
                BtnEvict(asset: asset)
                if Config.isDesktop {
                    BtnShowInFinder(url: asset.url, autoResize: false)
                }
                Divider()
                BtnDel(assets: [asset], autoResize: false)
            }))
    }

    private func getImageName() -> String {
        return "ellipsis.circle"
    }
}

#Preview("Layout") {
    LayoutView()
}
