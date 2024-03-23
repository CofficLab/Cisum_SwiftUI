import SwiftUI

struct ButtonPlay: View {
    @EnvironmentObject var audioManager: AudioManager
    
    var url: URL
        
    var body: some View {
        Button {
            audioManager.playFile(url: url)
        } label: {
            Label("播放", systemImage: getImageName())
                .font(.system(size: 24))
        }
    }
    
    private func getImageName() -> String {
        return "play.fill"
    }
}
