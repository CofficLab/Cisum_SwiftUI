import OSLog
import SwiftUI

struct AlbumView: View {
    var audio: Audio
    var downloadingPercent: Double = 100.0
    var fileManager = FileManager.default
    var withBackground = false
    var image: Image? { getCoverFromDisk() }

    var body: some View {
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
                DefaultCover(withBackground: withBackground)
            }
        }
    }

    func getCoverFromDisk() -> Image? {
        guard let coverPath = audio.cover else {
            return nil
        }

        if fileManager.fileExists(atPath: coverPath.path) {
            #if os(macOS)
                return Image(nsImage: NSImage(contentsOf: coverPath)!)
            #else
                return Image(uiImage: UIImage(contentsOfFile: coverPath.path)!)
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
