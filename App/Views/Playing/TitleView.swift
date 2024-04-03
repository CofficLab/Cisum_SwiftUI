import SwiftUI

struct TitleView: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var audioManager: AudioManager
    
    var body: some View {
        VStack {
            if audioManager.audio == nil {
                Label("无可播放的文件", systemImage: "info.circle")
                    .foregroundStyle(.white)
            } else if let audio = audioManager.audio {
                Text(audio.title).foregroundStyle(.white)
                    .font(.title2)

                Text(audio.artist).foregroundStyle(.white)
            } else {
                Label("状态未知", systemImage: "info.circle")
                    .foregroundStyle(.white)
            }
        }
    }
}

#Preview("APP") {
    RootView {
        ContentView()
    }
}
