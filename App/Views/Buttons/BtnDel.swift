import SwiftUI

struct BtnDel: View {
    @EnvironmentObject var db: DB
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var audioManager: AudioManager

    var audios: Set<Audio.ID>
    var callback: () -> Void = {}
    var autoResize = false

    var body: some View {
        ControlButton(
            title: "删除 \(audios.count) 个",
            tips: "彻底删除，不可恢复",
            image: getImageName(),
            dynamicSize: autoResize,
            onTap: {
                Task {
                    //appManager.stateMessage = "正在删除 \(audios.count) 个"

                    let isPlaying = audioManager.player.isPlaying
                    let next = await db.deleteAudios(Array(audios))

                    if let audio = audioManager.audio, audios.contains(audio.persistentModelID) {
                        if isPlaying, let next = next {
                            audioManager.play(next, reason: "删除了")
                        } else {
                            audioManager.prepare(next, reason: "删除了")
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

#Preview("Layout") {
    LayoutView()
}
