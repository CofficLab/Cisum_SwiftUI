import OSLog
import SwiftUI

struct AlbumView: View {
    @EnvironmentObject var audioManager: AudioManager
    
    @State var audio: Audio?
    
    var downloadings: [Audio] { audioManager.downloadingItems }
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
                Coffee(rotate: rotate, withBackground: withBackground)
            }
        }
        .onChange(of: downloadings, {
            if let a = audio, let newAudio = downloadings.first(where: {$0.id == a.id}) {
                self.audio = newAudio
            } else {
                self.audio?.isDownloading = false
            }
        })
//        .background(.green)
    }

    func getCoverFromDisk() -> Image? {
        guard let audio = audio, let coverPath = audio.cover else {
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
