import OSLog
import SwiftUI

struct AlbumView: View {
    static var verbose = false
    static var label = "🐰 AlbumView::"

    @EnvironmentObject var audioManager: PlayManager

    @State var image: Image?
    @State var isDownloaded: Bool = true
    @State var isDownloading: Bool = false
    @State var downloadingPercent: Double = 0

    var e = EventManager()
    var main = Config.mainQueue
    var bg = Config.bgQueue
    var asset: PlayAsset
    var url: URL
    var forPlaying: Bool = false
    var fileManager = FileManager.default
    var verbose: Bool { Self.verbose }
    var label: String { "\(Logger.isMain)\(Self.label)" }
    var isNotDownloaded: Bool { !isDownloaded }
    var shape: RoundedRectangle {
        if forPlaying {
            if Config.isiOS {
                RoundedRectangle(cornerSize: CGSize(width: 20, height: 10))
            } else {
                RoundedRectangle(cornerSize: CGSize(width: 0, height: 0))
            }
            
        } else {
            RoundedRectangle(cornerSize: CGSize(width: 20, height: 10))
        }
    }

    /// forPlaying表示显示在正在播放界面
    init(_ audio: PlayAsset, forPlaying: Bool = false) {
        self.asset = audio
        url = audio.url
        self.forPlaying = forPlaying
    }

    var body: some View {
        ZStack {
            if asset.isNotExists() {
                Image(systemName: "minus.circle").resizable().scaledToFit()
            } else if isDownloading {
                Self.makeProgressView(downloadingPercent / 100)
            } else if isNotDownloaded {
                NotDownloadedAlbum(forPlaying: forPlaying).onTapGesture {
                    Task {
                        await audioManager.db.download(self.asset.url, reason: "点击了Album")
                    }
                }
            } else if let image = image {
                image.resizable().scaledToFit()
            } else {
                DefaultAlbum(forPlaying: forPlaying)
            }
        }
        .clipShape(shape)
        .onAppear {
            bg.async {
                let isDownloaded = asset.isDownloaded()
                let isDownloading = asset.isDownloading()
                let image = asset.getCoverImageFromCache()
                
                main.async {
                    self.isDownloaded = isDownloaded
                    self.isDownloading = isDownloading
                    self.image = image
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name.AudiosUpdatedNotification)) { notification in
            let data = notification.userInfo as! [String: [MetaWrapper]]
            let items = data["items"]!
            for item in items {
                if item.isDeleted {
                    continue
                }

                if item.url == self.url {
                    return refresh(item)
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name.AudioUpdatedNotification)) { notification in
            let data = notification.userInfo as! [String: Audio]
            let audio = data["audio"]!

            if audio.url == self.url {
                return refresh(audio)
            }
        }
    }

    func setCachedCover() {
        Task.detached(priority: .low, operation: {
            let image = await asset.getCoverImageFromCache()

            DispatchQueue.main.async {
                self.image = image
            }
        })
    }

    func refresh(_ audio: Audio, verbose: Bool = false) {
        if verbose {
            os_log("\(self.label)Refresh -> \(audio.title)")
        }

        if isDownloaded && image == nil {
            updateCover()
        }
    }

    func refresh(_ item: MetaWrapper? = nil, verbose: Bool = false) {
        if verbose {
            os_log("\(self.label)Refresh -> \(asset.title)")
        }

        if let item = item {
            isDownloaded = item.downloadProgress == 100
            isDownloading = item.isDownloading
            downloadingPercent = item.downloadProgress
        } else {
            bg.async {
                let isDownloaded = asset.isDownloaded()
                let isDownloading = asset.isDownloading()
                main.async {
                    self.isDownloaded = isDownloaded
                    self.isDownloading = isDownloading
                }
            }
            
        }

        if isDownloaded && image == nil {
            updateCover()
        }
    }

    func updateCover(verbose: Bool = false) {
        Task.detached(priority: .background) {
            if verbose {
                let label = await AlbumView.label
                let audio = await self.asset
                os_log("\(Logger.isMain)\(label)UpdateCover -> \(audio.title)")
            }

            let image = await asset.getCoverImage()

            DispatchQueue.main.async {
                self.image = image
            }
        }
    }

    static func makeProgressView(_ value: CGFloat = 0.5) -> some View {
        GeometryReader { geo in
            ZStack {
                ProgressView(value: value)
                    .progressViewStyle(CircularProgressViewStyle(size: min(geo.size.width, geo.size.height) * 0.8))
                if value < 1 {
                    Text("\(String(format: "%.0f", value * 100))")
                        .font(.system(size: min(geo.size.width, geo.size.height) * 0.56))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview("APP") {
    AppPreview()
        .frame(height: 800)
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
            width: Config.isDesktop ? 36 : 36,
            height: Config.isDesktop ? 36 : 36
        ).background(.red.opacity(0.2))
        HStack {
            AlbumView.makeProgressView().frame(
                width: Config.isDesktop ? 48 : 36,
                height: Config.isDesktop ? 36 : 36
            )
            Text("2")
        }.background(.blue.opacity(0.2))
    }.background(BackgroundView.type4)
}
