import OSLog
import SwiftUI

struct BtnMore: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var playMan: PlayMan

    @State var isDownloaded = true

    var asset: PlayAsset
    var autoResize = true

    var body: some View {
        ControlButton(
            title: "播放 「\(asset.fileName)」",
            image: getImageName(),
            dynamicSize: autoResize,
            onTap: {
                playMan.play(asset, reason: "Play Button")
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
