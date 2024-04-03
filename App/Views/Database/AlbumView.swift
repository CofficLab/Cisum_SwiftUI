import OSLog
import SwiftUI

struct AlbumView: View {
    @EnvironmentObject var audioManager: AudioManager
    
    @State var audio: Audio?
    
    var downloadings: [Audio] { audioManager.downloadingItems }
    var downloaded: [Audio] { audioManager.downloadedItems }
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
        .onChange(of: downloadings, {
            if let a = audio, let newAudio = downloadings.first(where: {$0.id == a.id}) {
                os_log("🍋 AlbumView::downloading \(a.title) \(a.downloadingPercent)")
                self.audio = newAudio
            }
        })
        .onChange(of: downloaded, {
            AppConfig.bgQueue.async {
                if let a = audio, let newAudio = downloaded.first(where: {$0.id == a.id}) {
                    AppConfig.mainQueue.async {
                        self.audio = newAudio
                    }
                }
            }
        })
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
