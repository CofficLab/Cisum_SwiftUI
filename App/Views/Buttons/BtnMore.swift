import OSLog
import SwiftUI

struct BtnMore: View {
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
            },
            menus: AnyView(VStack{
                BtnPlay(audio: audio, autoResize: false)
                Divider()
                BtnDownload(audio: audio)
                BtnEvict(audio: audio)
                if AppConfig.isDesktop {
                    BtnShowInFinder(url: audio.url, autoResize: false)
                }
                Divider()
                BtnDel(audios: [audio.id], autoResize: false)
            }))
    }

    private func getImageName() -> String {
        return "ellipsis.circle"
    }
}

#Preview("Layout") {
    LayoutView()
}
