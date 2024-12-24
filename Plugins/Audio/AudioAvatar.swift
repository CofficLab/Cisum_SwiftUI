import MagicKit
import OSLog
import SwiftUI

struct AudioAvatar: View, SuperLog, SuperThread {
    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var m: MessageProvider

    static let emoji = "🐰"

    @State var image: Image?
    @State var downloadingPercent: Double = -1
    @State var displayedPercent: Int = 0

    var isDownloading: Bool { downloadingPercent > 0 && downloadingPercent < 100 }
    var isNotDownloaded: Bool { !isDownloaded }
    var isDownloaded: Bool { downloadingPercent == 100 }

    var asset: PlayAsset
    var role: CoverView.Role = .Icon
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

    private var avatarContent: some View {
        Group {
            if asset.isNotExists() {
                Image(systemName: "minus.circle").resizable().scaledToFit()
            } else if isDownloading {
                ProgressView(value: downloadingPercent, total: 100) {
                    Text("\(displayedPercent)")
                }.progressViewStyle(CircularProgressViewStyle(size: 35))
            } else if isNotDownloaded {
                NotDownloadedAlbum(role: role)
            } else if let image = image {
                image.resizable().scaledToFit()
            } else {
                DefaultAlbum(role: role)
            }
        }
    }

    var body: some View {
        avatarContent
            .clipShape(shape)
            .onAppear(perform: handleOnAppear)
            .onChange(of: isDownloaded, handleDownloadCompletion)
            .onReceive(NotificationCenter.default.publisher(for: .dbSyncing), perform: handleDBSyncing)
    }

    func updateCover(reason: String, verbose: Bool = false) {
        Task {
            if verbose {
                os_log("\(t)🪞🪞🪞 UpdateCover for \(self.asset.title) Because of \(reason)")
            }

            do {
                let image = try await asset.getCoverImage()

                await MainActor.run {
                    self.image = image
                }
            } catch {
                self.m.toast("\(error.localizedDescription)")
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

// MARK: Event Handler

extension AudioAvatar {
    func handleOnAppear() {
        self.downloadingPercent = asset.isDownloaded ? 100 : 0
    }

    private func handleDownloadCompletion() {
        if isDownloaded {
            updateCover(reason: "下载完成")
        }
    }

    func handleDBSyncing(_ notification: Notification) {
        if let group = notification.userInfo?["group"] as? DiskFileGroup {
            for file in group.files {
                if file.url == self.asset.url {
                    self.downloadingPercent = file.downloadProgress
                    self.displayedPercent = Int(file.downloadProgress)
                    break
                }
            }
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
