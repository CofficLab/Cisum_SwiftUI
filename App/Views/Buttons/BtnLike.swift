import SwiftUI

struct BtnLike: View {
    @EnvironmentObject var audioManager: AudioManager
    
    @State var like = false
    
    var audio: Audio
    var title: String {
        audio.like ? "取消标记为喜欢" : "标记为喜欢"
    }
        
    var body: some View {
        ControlButton(title: title, systemImage: getImageName(), onTap: {
            Task {
                if audio.like {
                    await audioManager.db.dislike(audio)
                    self.like = false
                } else {
                    await audioManager.db.like(audio)
                    self.like = true
                }
            }
        })
        .onAppear {
            self.like = audio.like
        }
        .onChange(of: audio, {
            self.like = audio.like
        })
    }
    
    private func getImageName() -> String {
        return like ? "star.fill" : "star"
    }
}

#Preview("Layout") {
    LayoutView()
}
