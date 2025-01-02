import MagicKit
import MagicUI
import OSLog
import SwiftUI

struct BookPlayingCover: View, SuperLog, SuperThread {
    @EnvironmentObject var playMan: PlayMan
    @EnvironmentObject var app: AppProvider

    @State var image: Image?
    @State var downloadingPercent: Double = -1
    @State var asset: PlayAsset?

    var isDownloading: Bool { downloadingPercent > 0 && downloadingPercent < 100 }
    var isNotDownloaded: Bool { !isDownloaded }
    var isDownloaded: Bool { downloadingPercent == 100 }
    var updating: [DiskFile] = []
    var shape: RoundedRectangle {
        if Config.isiOS {
            RoundedRectangle(cornerSize: CGSize(width: 20, height: 10))
        } else {
            RoundedRectangle(cornerSize: CGSize(width: 0, height: 0))
        }
    }

    static let emoji = "🥇"
    var alignTop = false

    var body: some View {
        ZStack {
            Text("EEEEEE")
            if alignTop {
                VStack {
                    view
                    Spacer()
                }
            } else {
                if Config.isiOS {
                    view.padding(.horizontal)
                } else {
                    view
                }
            }
        }
        .onAppear(perform: onAppear)
//        .onReceive(NotificationCenter.default.publisher(for: .PlayManStateChange), perform: onPlayStateChange)
        .onChange(of: isDownloaded, onDownloadedChange)
        .onChange(of: updating, onUpdatingChange)
    }

    var view: some View {
        ZStack {
            if let asset = asset {
                bookImage.id(asset.url)
            } else {
                DefaultAlbum(role: .Hero)
            }
        }
    }

    var bookImage: some View {
        ZStack {
            if let asset = asset {
                if asset.url.isNotFileExist {
                    Image(systemName: "minus.circle").resizable().scaledToFit()
                } else if isDownloading {
                    Self.makeProgressView(downloadingPercent / 100)
                } else if isNotDownloaded {
                    NotDownloadedAlbum(role: .Hero)
                } else if let image = image {
                    image.resizable().scaledToFit()
                } else {
                    DefaultAlbum(role: .Hero)
                }
            }
        }
        .clipShape(shape)
    }

    func updateCover(reason: String, verbose: Bool = true) {
        guard let asset = asset else {
            return
        }

        let title = asset.title

        if verbose {
            os_log("\(t)UpdateCover for \(title) 🐛 \(reason)")
        }
        
        self.downloadingPercent = asset.url.isDownloaded ? 100 : 0

//        Task {
//            guard let book = await self.data.db.findBook(asset.url) else {
//                os_log(.error, "No Book Found")
//                return
//            }
//
//            let image = await self.data.db.getCover(book.url)
//
//            if image != self.image {
//                self.image = image
//            }
//        }
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

// MARK: Event Handler

extension BookPlayingCover {
    func onPlayStateChange(_ notification: Notification) {
        let asset = playMan.asset

        if asset != self.asset {
            os_log("\(self.t)PlayAssetChange")
            withAnimation {
                self.asset = asset
            }
        }

        self.updateCover(reason: "PlayAssetChange")
    }

    func onAppear() {
        self.asset = playMan.asset

        if let asset = self.asset {
            self.downloadingPercent = asset.url.isDownloaded ? 100 : 0
        }
    }

    func onDownloadedChange() {
        if isDownloaded {
            updateCover(reason: "下载完成")
        }
    }

    func onUpdatingChange() {
        guard let asset = asset else {
            return
        }

        for file in updating {
            if file.url == asset.url {
                self.downloadingPercent = file.downloadProgress
            }
        }
    }
}

#Preview("APP") {
    AppPreview()
}

#Preview("Layout") {
    LayoutView()
}
