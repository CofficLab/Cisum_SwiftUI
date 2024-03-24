import SwiftUI

struct DBCell: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var audioManager: AudioManager
    
    var audio: AudioModel
    
    init(_ audio: AudioModel) {
        self.audio = audio
    }
    
    var body: some View {
        HStack {
            if audio == audioManager.audio {
                Image(systemName: "signpost.right").frame(width: 16)
            } else {
                audio.getIcon()
            }

            AlbumView(audio: Binding.constant(audio)).frame(width: 24, height: 24)

            Text(audio.title)
        }
        .onTapGesture(count: 2, perform:  playNow)
    }
}

extension DBCell {
    private func playNow() {
        if audio.isDownloading {
            appManager.alertMessage = "正在下载，不能播放"
            appManager.showAlert = true
        } else {
            audioManager.playFile(url: audio.url)
        }
    }
}

#Preview("APP") {
    RootView {
        ContentView(play: false)
    }
}
