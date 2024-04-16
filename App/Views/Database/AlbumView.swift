import OSLog
import SwiftUI

struct AlbumView: View {
    @EnvironmentObject var audioManager: AudioManager
    
    @State var image: Image? = nil
    @State var isDownloaded: Bool = true
    @State var isDownloading: Bool = false
    @State var downloadingPercent: Double = 0

    var main = AppConfig.mainQueue
    var bg = AppConfig.bgQueue
    var audio: Audio
    var forPlaying: Bool = false
    var fileManager = FileManager.default
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
        .onAppear {
            refresh()
            
            // 监听到了事件，注意要考虑audio已经被删除了的情况
            EventManager().onUpdated({ items in
                for item in items {
                    if item.isDeleted {
                        continue
                    }
                    
                    if item.url == audio.url {
                        return refresh(item)
                    }
                }
            })
        }
        .onDisappear {
            EventManager().removeListener(self)
        }
    }

    func refresh(_ item: MetadataItemWrapper? = nil) {
        
        //os_log("\(Logger.isMain)🍋 AlbumView::refresh -> \(audio.title) \(percent)")

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
        // os_log("\(Logger.isMain)📷 AlbumView::getCover")
//        if audio.isNotExists {
//            return
//        }

        Task {
            let image = await audio.getCoverImage()
//            main.sync {
                self.image = image
//            }
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
