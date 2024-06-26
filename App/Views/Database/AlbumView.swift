import OSLog
import SwiftUI

struct AlbumView: View {
    @EnvironmentObject var dataManager: DataManager
    
    static var verbose = false
    static var label = "🐰 AlbumView::"
    
    @State var image: Image?
    
    // MARK: Download
    
    var isDownloading: Bool { downloadingPercent > 0 && downloadingPercent < 100}
    var isNotDownloaded: Bool { !isDownloaded }
    var isDownloaded: Bool {
        let result = downloadingPercent == 100
        
        if result {
            updateCover()
        }
        
        return result
    }
    var downloadingPercent: Double {
        for file in updating.files {
            if file.url == url {
                return file.downloadProgress
            }
        }
        
        return asset.isDownloaded ? 100 : 0
    }
    
    var main = Config.mainQueue
    var bg = Config.bgQueue
    var asset: PlayAsset
    var url: URL
    var forPlaying: Bool = false
    var fileManager = FileManager.default
    var verbose: Bool { Self.verbose }
    var label: String { "\(Logger.isMain)\(Self.label)" }
    var updating: DiskFileGroup { dataManager.updating }
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
                        dataManager.disk.download(self.asset.url, reason: "点击了Album")
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
            updateCover()
        }
    }

    func updateCover(verbose: Bool = false) {
        Task.detached(priority: .background) {
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
