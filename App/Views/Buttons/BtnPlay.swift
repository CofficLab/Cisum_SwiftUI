import SwiftUI

struct BtnPlay: View {
    @EnvironmentObject var audioManager: AudioManager
    
    var audio: AudioModel
        
    var body: some View {
        Button {
            audioManager.play(audio)
        } label: {
            Label("播放", systemImage: getImageName())
                .font(.system(size: 24))
        }
    }
    
    private func getImageName() -> String {
        return "play.fill"
    }
}
