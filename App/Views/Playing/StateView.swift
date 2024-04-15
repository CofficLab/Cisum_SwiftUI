import SwiftUI

struct StateView: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var audioManager: AudioManager

    private var audio: Audio? { audioManager.audio }
    @State private var next: Audio?

    var body: some View {
        ZStack {
            if let audio = audio {
                HStack(spacing: 2) {
                    Text(audio.isDownloading ? "下载中" : "已下载")
                    if let n = next {
                        Text("下一首：\(n.title)")
                    } else {
                        Text("无下一首")
                    }
                }
                .onAppear {
                    Task {
                        self.next = audioManager.db.nextOf(audio)
                    }
                }
                .onChange(of: audio, {
                    Task {
                        self.next = audioManager.db.nextOf(audio)
                    }
                })
            }
        }
    }
}

#Preview("APP") {
    AppPreview()
}
