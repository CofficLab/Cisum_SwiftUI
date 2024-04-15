import SwiftUI

struct BtnLike: View {
    @EnvironmentObject var audioManager: AudioManager
    
    var audio: Audio
    var title: String {
        audio.like ? "取消标记为喜欢" : "标记为喜欢"
    }
        
    var body: some View {
        ControlButton(title: title, size: 28, systemImage: getImageName(), onTap: {
            Task {
                if audio.like {
                    await audioManager.db.dislike(audio)
                } else {
                    await audioManager.db.like(audio)
                }
            }
        })
    }
    
    private func getImageName() -> String {
        return audio.like ? "star.fill" : "star"
    }
}

#Preview("Layout") {
    LayoutView()
}
