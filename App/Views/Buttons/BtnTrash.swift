import SwiftUI

struct BtnTrash: View {
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var appManager: AppManager
    
    var audio: Audio
        
    var body: some View {
        Button {
            Task {
                await audioManager.db.trash(audio)
            }
        } label: {
            Label("将「\(audio.title)」放入回收站", systemImage: getImageName())
                .font(.system(size: 24))
        }
    }
    
    private func getImageName() -> String {
        return "trash"
    }
}
