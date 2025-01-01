import OSLog
import SwiftUI
import MagicPlayMan

struct BtnMore: View {
    @EnvironmentObject var appManager: AppProvider
    @EnvironmentObject var playMan: MagicPlayMan

    @State var isDownloaded = true

    var asset: MagicAsset
    var autoResize = true

    var body: some View {
        ControlButton(
            title: "播放 「\(asset.title)」",
            image: getImageName(),
            dynamicSize: autoResize,
            onTap: {
                playMan.play(asset, reason: "Play Button", verbose: true)
            },
            menus: AnyView(VStack {
                BtnToggle(autoResize: false)
                Divider()
                BtnDownload(asset: asset)
                BtnEvict(asset: asset)
                if Config.isDesktop {
                    BtnShowInFinder(url: asset.url, autoResize: false)
                }
                Divider()
                BtnDel(assets: [asset], autoResize: false)
            }
                .labelStyle(.titleOnly)
            ))
    }

    private func getImageName() -> String {
        return "ellipsis.circle"
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}

#Preview("Layout") {
    LayoutView()
}
