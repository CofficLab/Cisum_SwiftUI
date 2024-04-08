import OSLog
import SwiftUI

struct AlbumView: View {
    @State var image: Image? = nil
    @State var isDownloaded: Bool = true
    @State var isDownloading: Bool = false
    @State var downloadingPercent: Double = 0

    var audio: Audio
    var fileManager = FileManager.default
    var isNotDownloaded: Bool { !isDownloaded && !isDownloading }

    init(_ audio: Audio) {
        self.audio = audio
    }

    var body: some View {
        ZStack {
            if isDownloading {
                    ProgressView(value: downloadingPercent / 100)
                        .progressViewStyle(CircularProgressViewStyle(size: 22))
                        .controlSize(.regular)
                        .scaledToFit()
                
                Text("\(String(format: "%.0f",downloadingPercent))").scaleEffect(0.8)
            } else if isNotDownloaded {
                Image(systemName: "arrow.down.circle.dotted").resizable().scaledToFit()
            } else if let image = image {
               image.resizable().scaledToFit()
            } else {
                Image("DefaultAlbum").resizable().scaledToFit()
                    .task(priority: .utility) {
                        await updateCover()
                    }
            }
        }
        .task {
            isDownloaded = audio.isDownloaded
            isDownloading = iCloudHelper.isDownloading(audio.url)
            await CloudHandler().startMonitoringFile(at: audio.url, onDidChange: {
                isDownloaded = iCloudHelper.isDownloaded(url: audio.url)
                isDownloading = iCloudHelper.isDownloading(audio.url)
            })
            self.listen()
        }.onDisappear {
            Task {
                await CloudHandler().stopMonitoringFile(at: audio.url)
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name("Updated"), object: nil)
            }
        }
    }

    func updateCover() async {
        // os_log("\(Logger.isMain)📷 AlbumView::getCover")
        let image = await audio.getCoverImage()
        self.image = image
    }

    func listen() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("Updated"),
            object: nil,
            queue: .main,
            using: { notification in
                AppConfig.bgQueue.async {
                    let data = notification.userInfo as! [String: [MetadataItemWrapper]]
                    let items = data["items"]!
                    for item in items {
                        if item.url == audio.url {
                            //os_log("\(Logger.isMain)🖥️ Row::detect updated of \(audio.title) -> \(audio.downloadingPercent)")
                            self.downloadingPercent = item.downloadProgress
                            self.isDownloading = item.isDownloading
                            self.isDownloaded = item.downloadProgress == 100
                            return
                        }
                    }
                }
            }
        )
    }
}

#Preview("APP") {
    RootView {
        ContentView()
    }
}
