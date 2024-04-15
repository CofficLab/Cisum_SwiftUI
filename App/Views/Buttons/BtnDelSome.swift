import SwiftUI

struct BtnDelSome: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var audioManager: AudioManager
    
    var audios: Set<Audio.ID>
    var callback: ()->Void = {}
    
    var body: some View {
        ControlButton(
            title: "删除 \(audios.count) 个",
            size: 28,
            tips: "彻底删除，不可恢复",
            systemImage: getImageName(),
            onTap: {
            Task {
                appManager.stateMessage = "正在删除 \(audios.count) 个"
                await audioManager.db.delete(Array(audios))
                appManager.stateMessage = ""
                appManager.setFlashMessage("已删除")
                audioManager.next(manual: true)
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
