import OSLog
import SwiftUI

struct AlbumView: View {
    static var verbose = true
    static var label = "🐰 AlbumView::"
    
    @EnvironmentObject var audioManager: AudioManager

    @State var image: Image? = nil
    @State var isDownloaded: Bool = true
    @State var isDownloading: Bool = false
    @State var downloadingPercent: Double = 0

    var e = EventManager()
    var main = AppConfig.mainQueue
    var bg = AppConfig.bgQueue
    var audio: Audio
    var url: URL
    var forPlaying: Bool = false
    var fileManager = FileManager.default
    var verbose: Bool { Self.verbose }
    var label: String { "\(Logger.isMain)\(Self.label)" }
    var isNotDownloaded: Bool { !isDownloaded }
    var shape: RoundedRectangle {
        if forPlaying {
            RoundedRectangle(cornerSize: CGSize(width: 0, height: 0))
        } else {
            RoundedRectangle(cornerSize: CGSize(width: 20, height: 10))
        }
    }

    /// forPlaying表示显示在正在播放界面
    init(_ audio: Audio, forPlaying: Bool = false) {
        self.audio = audio
        url = audio.url
        self.forPlaying = forPlaying
    }

    var body: some View {
        ZStack {
            if audio.isNotExists {
                Image(systemName: "minus.circle").resizable().scaledToFit()
            } else if isDownloading {
                Self.makeProgressView(downloadingPercent / 100)
            } else if isNotDownloaded {
                NotDownloadedAlbum(forPlaying: forPlaying).onTapGesture {
                    Task {
                        await audioManager.db.download(self.audio, reason: "点击了Album")
                    }
                }
            } else if let image = image {
                image.resizable().scaledToFit()
            } else {
                DefaultAlbum(forPlaying: forPlaying)
            }
        }
        .clipShape(shape)
        .onHover(perform: { _ in
            refresh()
        })
        .onAppear {
            refresh()

            // 监听到了事件，注意要考虑audio已经被删除了的情况
            e.onUpdated { items in
                for item in items {
                    if item.isDeleted {
                        continue
                    }

                    if item.url == self.url {
                        return refresh(item)
                    }
                }
            }
        }
        .onDisappear {
            e.removeListener(self)
        }
    }

    func refresh(_ item: MetadataItemWrapper? = nil) {
        if verbose {
            os_log("\(self.label)Refresh -> \(audio.title)")
        }

        isDownloaded = audio.isDownloaded
        isDownloading = iCloudHelper.isDownloading(audio.url)

        if let item = item {
            isDownloaded = item.downloadProgress == 100
            isDownloading = item.isDownloading
            downloadingPercent = item.downloadProgress
        }

        if isDownloaded {
            updateCover()
        }
    }

    func updateCover() {
        Task.detached(priority: .background) {
            if await AlbumView.verbose {
                let label = await AlbumView.label
                let audio = await self.audio
                os_log("\(Logger.isMain)\(label)UpdateCover -> \(audio.title)")
            }

            let image = await audio.getCoverImage()

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
            width: ViewConfig.isDesktop ? 36 : 36,
            height: ViewConfig.isDesktop ? 36 : 36
        ).background(.red.opacity(0.2))
        HStack {
            AlbumView.makeProgressView().frame(
                width: ViewConfig.isDesktop ? 48 : 36,
                height: ViewConfig.isDesktop ? 36 : 36
            )
            Text("2")
        }.background(.blue.opacity(0.2))
    }.background(BackgroundView.type4)
}
