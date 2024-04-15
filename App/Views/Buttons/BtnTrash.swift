import SwiftUI

struct BtnTrash: View {
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var appManager: AppManager
    
    var audio: Audio
        
    var body: some View {
        ControlButton(title: "将「\(audio.title)」放入回收站", size: 28, systemImage: getImageName(), onTap: {
            audioManager.dbFolder.trash(audio)
            audioManager.next(manual: true)
        })
    }
    
    private func getImageName() -> String {
        return "trash"
    }
}

#Preview("Layout") {
    LayoutView()
}
