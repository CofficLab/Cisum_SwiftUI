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
            } else if isDownloading && downloadingPercent < 100 {
                Self.makeProgressView(downloadingPercent / 100)
            } else if isNotDownloaded {
                Self.getNotDownloadedAlbum(forPlaying: forPlaying)
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
                        withAnimation {
                            self.isDownloading = item.isDownloading
                            self.isDownloaded = item.downloadProgress == 100
                        }
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
    
    static func getNotDownloadedAlbum(forPlaying: Bool = false) -> some View {
        ZStack {
            if forPlaying {
                HStack {
                    Spacer()
                    Image(systemName: "arrow.down.circle.dotted")
                        .resizable()
                        .scaledToFit()
                    Spacer()
                }
            } else {
                Image(systemName: "arrow.down.circle.dotted")
                    .resizable()
                    .scaledToFit()
            }
        }
    }

    static func getDefaultAlbum(forPlaying: Bool = false) -> some View {
        ZStack {
            if forPlaying {
                HStack {
                    Spacer()
                    Image("PlayingAlbum")
                        .resizable()
                        .scaledToFit()
                        .rotationEffect(.degrees(-90))
                    Spacer()
                }
            } else {
                Image("DefaultAlbum")
                    .resizable()
                    .scaledToFit()
                    .rotationEffect(.degrees(-90))
            }
        }
    }

    static func makeProgressView(_ value: CGFloat = 0.5) -> some View {
        GeometryReader { geo in
            ZStack {
                ProgressView(value: value)
                    .progressViewStyle(CircularProgressViewStyle(size: min(geo.size.width, geo.size.height) * 0.8))
                Text("\(String(format: "%.0f", value * 100))")
                    .font(.system(size: min(geo.size.width, geo.size.height) * 0.56))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview("APP") {
    RootView {
        ContentView()
    }.modelContainer(AppConfig.getContainer())
}

#Preview("ProgressView") {
    AlbumView.makeProgressView()
        .frame(width: 300, height: 300)
        .background(BackgroundView.type2)
}

#Preview("List") {
    List {
        HStack {
            AlbumView.makeProgressView()
            Text("1")
        }.frame(
            width: UIConfig.isDesktop ? 36 : 36,
            height: UIConfig.isDesktop ? 36 : 36
        ).background(.red.opacity(0.2))
        HStack {
            AlbumView.makeProgressView().frame(
                width: UIConfig.isDesktop ? 48 : 36,
                height: UIConfig.isDesktop ? 36 : 36
            )
            Text("2")
        }.background(.blue.opacity(0.2))
    }.background(BackgroundView.type4)
}
