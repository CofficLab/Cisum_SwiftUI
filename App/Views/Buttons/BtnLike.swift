import OSLog
import SwiftUI

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
            image: getImageName(),
            dynamicSize: autoResize,
            onTap: {
                Task {
                    await audioManager.db.toggleLike(audio)
                }
            })
            .onAppear {
                self.like = audio.like
            }
            .onChange(of: audio) {
                self.like = audio.like
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name.AudioUpdatedNotification), perform: { notification in
                let data = notification.userInfo as! [String: Audio]
                let audio = data["audio"]!
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
