import OSLog
import SwiftUI

struct BtnMore: View {
    @EnvironmentObject var audioManager: PlayManager
    @EnvironmentObject var appManager: AppManager

    @State var isDownloaded = true

    var audio: Audio
    var autoResize = true
    var player: PlayMan { audioManager.playMan }

    var body: some View {
        ControlButton(
            title: "播放 「\(audio.title)」",
            image: getImageName(),
            dynamicSize: autoResize,
            onTap: {
                player.play(audio.toPlayAsset(), reason: "Play Button")
            },
            menus: AnyView(VStack{
                BtnPlay(audio: audio, autoResize: false)
                Divider()
                BtnDownload(audio: audio)
                BtnEvict(audio: audio)
                if Config.isDesktop {
                    BtnShowInFinder(url: audio.url, autoResize: false)
                }
                Divider()
                BtnDel(audios: [audio], autoResize: false)
            }))
    }

    private func getImageName() -> String {
        return "ellipsis.circle"
    }
}

#Preview("Layout") {
    LayoutView()
}
