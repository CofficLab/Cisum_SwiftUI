import SwiftUI

struct BtnDel: View {
    @EnvironmentObject var db: DB
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var audioManager: PlayManager

    var audios: [Audio]
    var callback: () -> Void = {}
    var autoResize = false
    var playMan: PlayMan { audioManager.playMan }

    var body: some View {
        ControlButton(
            title: "删除 \(audios.count) 个",
            tips: "彻底删除，不可恢复",
            image: getImageName(),
            dynamicSize: autoResize,
            onTap: {
                Task {
                    //appManager.stateMessage = "正在删除 \(audios.count) 个"

                    let isPlaying = audioManager.playMan.isPlaying
                    let next = await db.deleteAudios(audios)

                    if let asset = audioManager.asset, audios.map({ $0.url }).contains(asset.url) {
                        if isPlaying, let next = next {
                            playMan.play(next.toPlayAsset(), reason: "删除了")
                        } else {
                            playMan.prepare(next?.toPlayAsset())
                        }
                    }

                    appManager.setFlashMessage("已删除")
                    appManager.cleanStateMessage()
                    callback()
                }
            })
    }

    private func getImageName() -> String {
        return "trash"
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}

#Preview("Layout") {
    LayoutView()
}
