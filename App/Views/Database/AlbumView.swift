import OSLog
import SwiftUI

struct AlbumView: View {
    @EnvironmentObject var audioManager: AudioManager
    
    @State var audio: Audio?
    
    var fileManager = FileManager.default
    var withBackground = false
    var rotate = true
    var image: Image? { getCoverFromDisk() }

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
                        Coffee(rotate: rotate, withBackground: withBackground)
                    }
                }
            } else {
//                Coffee(rotate: rotate, withBackground: withBackground)
            }
        }
    }

    func getCoverFromDisk() -> Image? {
        guard let audio = audio, let coverURL = audio.coverURL else {
            return nil
        }

        if fileManager.fileExists(atPath: coverURL.path) {
            #if os(macOS)
            return Image(nsImage: NSImage(contentsOf: coverURL)!)
            #else
                return Image(uiImage: UIImage(contentsOfFile: coverURL.path)!)
            #endif
        }

        return nil
    }
}

#Preview("APP") {
    RootView {
        ContentView()
    }
}
