import SwiftUI

struct BtnDelSome: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var audioManager: AudioManager
    
    var audios: Set<Audio.ID>
    var callback: ()->Void = {}
        
    var body: some View {
        Button {
            Task {
                appManager.stateMessage = "正在删除 \(audios.count) 个"
//                await audioManager.delete(urls: audios)
                appManager.stateMessage = ""
                appManager.setFlashMessage("已删除")
                callback()
            }
        } label: {
            Label("删除 \(audios.count) 个", systemImage: getImageName())
                .font(.system(size: 24))
        }
    }
    
    private func getImageName() -> String {
        return "trash"
    }
}

#Preview("Layout") {
    LayoutView()
}
