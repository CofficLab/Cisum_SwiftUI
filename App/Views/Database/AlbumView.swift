import OSLog
import SwiftUI

struct AlbumView: View {
    @State var image: Image? = nil
    @State var isDownloaded: Bool = true
    @State var isDownloading: Bool = false
    @State var downloadingPercent: Double = 0

    var audio: Audio
    var forPlaying: Bool = false
    var fileManager = FileManager.default
    var isNotDownloaded: Bool { !isDownloaded && !isDownloading }

    /// forPlaying表示显示在正在播放界面
    init(_ audio: Audio, forPlaying: Bool = false) {
        self.audio = audio
        self.forPlaying = forPlaying
    }

    var body: some View {
        ZStack {
            if audio.isNotExists {
                Image(systemName: "minus.circle").resizable().scaledToFit()
            } else if isDownloading {
                ProgressView(value: downloadingPercent / 100)
                    .progressViewStyle(CircularProgressViewStyle(size: UIConfig.isDesktop ? 22 : 36))
                    .controlSize(.regular)
                    .scaledToFit()

                Text("\(String(format: "%.0f", downloadingPercent))").scaleEffect(0.8)
            } else if isNotDownloaded {
                Image(systemName: "arrow.down.circle.dotted").resizable().scaledToFit()
            } else if let image = image {
                image.resizable().scaledToFit()
            } else {
                Self.getDefaultAlbum(forPlaying: forPlaying)
            }
        }
        .task(priority: .utility) {
            await updateCover()
        }
        .onAppear {
            refresh()
            Task {
                await CloudHandler().startMonitoringFile(at: audio.url, onDidChange: refresh)
            }
        }.onDisappear {
            Task {
                await CloudHandler().stopMonitoringFile(at: audio.url)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("Updated")), perform: {
            notification in
            AppConfig.bgQueue.async {
                let data = notification.userInfo as! [String: [MetadataItemWrapper]]
                let items = data["items"]!
                for item in items {
                    if item.url == audio.url {
                        self.downloadingPercent = item.downloadProgress
                        self.isDownloading = item.isDownloading
                        self.isDownloaded = item.downloadProgress == 100
                        return
                    }
                }
            }
        })
        .onChange(of: audio) {
            refresh()
        }
    }

    func refresh() {
        if audio.isNotExists {
            isDownloaded = false
            return
        }

        isDownloaded = audio.isDownloaded
        isDownloading = iCloudHelper.isDownloading(audio.url)
    }

    func updateCover() async {
        // os_log("\(Logger.isMain)📷 AlbumView::getCover")
        if audio.isNotExists {
            return
        }

        let image = await audio.getCoverImage()
        self.image = image
    }
    
    static func getDefaultAlbum(forPlaying: Bool = false) -> some View {
        if forPlaying {
            Image("PlayingAlbum")
                .resizable()
                .scaledToFit()
                .rotationEffect(.degrees(-90))
        } else {
            Image("DefaultAlbum")
                .resizable()
                .scaledToFit()
                .rotationEffect(.degrees(-90))
        }
    }
}

#Preview("APP") {
    RootView {
        ContentView()
    }
}
