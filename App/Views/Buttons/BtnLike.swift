import SwiftUI
import OSLog

struct BtnLike: View {
    @EnvironmentObject var audioManager: AudioManager
    
    @State var like = false
    
    var audio: Audio
    var autoResize = false
    var title: String { audio.like ? "取消喜欢" : "标记喜欢" }
    var label: String { "\(Logger.isMain)❤️ BtnLike::" }
        
    var body: some View {
        ControlButton(
            title: title,
            systemImage: getImageName(),
            dynamicSize: autoResize,
            onTap: {
                Task {
                    await audioManager.db.toggleLike(audio)
                }
            })
            .onAppear {
                self.like = audio.like
                EventManager().onAudioUpdate({ audio in
                    //os_log("\(self.label)OnAudioUpdated with like -> \(audio.like)")
                    self.like = audio.like
                })
            }
            .onChange(of: audio) {
                self.like = audio.like
            }
    }
    
    private func getImageName() -> String {
        return like ? "star.fill" : "star"
    }
}

#Preview("Layout") {
    LayoutView()
}
