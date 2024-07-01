import OSLog
import SwiftUI

struct PictureView: View {
    @EnvironmentObject var app: AppManager
    @EnvironmentObject var data: DataManager
    
    static var label = "🐰 AlbumView::"
    
    @State var image: Image?
    @State var downloadingPercent: Double = -1
    
    // MARK: Download
    
    var isDownloading: Bool { downloadingPercent > 0 && downloadingPercent < 100}
    var isNotDownloaded: Bool { !isDownloaded }
    var isDownloaded: Bool { downloadingPercent == 100 }
    
    var asset: PlayAsset
    var role: CoverView.Role = .Icon
    var label: String { "\(Logger.isMain)\(Self.label)" }
    var updating: DiskFileGroup { data.updating }
    var shape: RoundedRectangle {
        if role == .Hero {
            if Config.isiOS {
                RoundedRectangle(cornerSize: CGSize(width: 20, height: 10))
            } else {
                RoundedRectangle(cornerSize: CGSize(width: 0, height: 0))
            }
            
        } else {
            RoundedRectangle(cornerSize: CGSize(width: 20, height: 10))
        }
    }

    init(_ asset: PlayAsset, role: CoverView.Role = .Icon) {
        self.asset = asset
        self.role = role
    }

    var body: some View {
        ZStack {
            if asset.isNotExists() {
                Image(systemName: "minus.circle").resizable().scaledToFit()
            } else if isDownloading {
                Self.makeProgressView(downloadingPercent / 100)
            } else if isNotDownloaded {
                NotDownloadedAlbum(role: role)
            } else if let image = image {
                image.resizable().scaledToFit()
            } else {
                DefaultAlbum(role: role)
            }
        }
        .clipShape(shape)
        .onAppear {
            if let file = updating.find(asset.url) {
                self.downloadingPercent = file.downloadProgress
            } else {
                self.downloadingPercent = asset.isDownloaded ? 100 : 0
            }
        }
        .onChange(of: isDownloaded, {
            if isDownloaded {
                updateCover(reason: "下载完成")
            }
        })
        .onChange(of: updating, {
            for file in updating.files {
                if file.url == asset.url {
                    self.downloadingPercent = file.downloadProgress
                }
            }
        })
    }

    func updateCover(reason: String, verbose: Bool = false) {
        let title = asset.title
        let label = Self.label
        Task.detached(priority: .background) {
            if verbose {
                os_log("\(Logger.isMain)\(label)UpdateCover for \(title) Because of \(reason)")
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
    PictureView.makeProgressView()
        .frame(width: 300, height: 300)
        .background(BackgroundView.type2)
}

#Preview("List") {
    List {
        HStack {
            PictureView.makeProgressView()
            Text("1")
        }.frame(
            width: Config.isDesktop ? 36 : 36,
            height: Config.isDesktop ? 36 : 36
        ).background(.red.opacity(0.2))
        HStack {
            PictureView.makeProgressView().frame(
                width: Config.isDesktop ? 48 : 36,
                height: Config.isDesktop ? 36 : 36
            )
            Text("2")
        }.background(.blue.opacity(0.2))
    }.background(BackgroundView.type4)
}
