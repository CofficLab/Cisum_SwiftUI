import SwiftUI

struct BtnDel: View {
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var appManager: AppManager
    
    var audio: Audio
        
    var body: some View {
        Button {
            audio.delete()
            appManager.setFlashMessage("\(audio.title) 已经删除")
        } label: {
            Label("删除「\(audio.title)」", systemImage: getImageName())
                .font(.system(size: 24))
        }
    }
    
    private func getImageName() -> String {
        return "trash"
    }
}
