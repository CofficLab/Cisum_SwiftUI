import OSLog
import SwiftUI

struct AlbumView: View {
    @EnvironmentObject var audioManager: AudioManager

    var audio: Audio
    var fileManager = FileManager.default
    var image: Image? { getCoverFromDisk() }
    
    init(_ audio: Audio) {
        self.audio = audio
    }

    var body: some View {
        ZStack {
            imageView
        }
    }

    var imageView: some View {
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
            return AnyView(Coffee(rotate: false))
        }
    }

    func getCoverFromDisk() -> Image? {
        guard let coverURL = audio.coverURL else {
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
