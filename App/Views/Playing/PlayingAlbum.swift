import OSLog
import SwiftUI

struct PlayingAlbum: View {
    @EnvironmentObject var audioManager: AudioManager
    
    @State var image: Image? = nil
    
    var audio: Audio? { audioManager.audio }
    var fileManager = FileManager.default
    var withBackground = false
    var rotate = true

    var body: some View {
        ZStack {
            if let audio = audio {
                if audio.isDownloading {
                    ProgressView(value: audio.downloadingPercent / 100)
                        .progressViewStyle(CircularProgressViewStyle(size: 14))
                        .controlSize(.regular)
                        .scaledToFit()
                } else if audio.isNotDownloaded {
                    Image(systemName: "arrow.down.circle.dotted").resizable().scaledToFit()
                } else {
                    if let image = image {
                        image.resizable().scaledToFit()
                    } else {
                        Image("PlayingAlbum").resizable().scaledToFit().rotationEffect(.degrees(-90))
                    }
                }
            } else {
                Image("PlayingAlbum").resizable().scaledToFit()
            }
        }.onAppear {
            Task {
                self.image = await audio?.getCoverImage()
            }
        }
    }
}

#Preview("APP") {
    RootView {
        ContentView()
    }
}
