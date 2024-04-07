import OSLog
import SwiftUI

struct AlbumView: View {
    @EnvironmentObject var audioManager: AudioManager
    
    @State var image: Image? = nil

    var audio: Audio
    var fileManager = FileManager.default
    
    init(_ audio: Audio) {
        self.audio = audio
    }

    var body: some View {
        ZStack {
            if audio.isDownloading {
                return AnyView(
                    ProgressView(value: audio.downloadingPercent / 100)
                        .progressViewStyle(CircularProgressViewStyle(size: 14))
                        .controlSize(.regular)
                        .scaledToFit()
                )
            }

            if audio.isNotDownloaded {
                return AnyView(
                    Image(systemName: "arrow.down.circle.dotted").resizable().scaledToFit()
                )
            }

            if let image = image {
                return AnyView(image.resizable().scaledToFit())
            } else {
                return AnyView(Image("DefaultAlbum").resizable().scaledToFit())
            }
        }.onAppear {
            Task.detached {
                //os_log("\(Logger.isMain)📷 AlbumView::getCover")
                let image = await audio.getCoverImage()
                DispatchQueue.main.async {
                    self.image = image
                }
            }
        }
    }
}

#Preview("APP") {
    RootView {
        ContentView()
    }
}
