import AVKit
import OSLog
import SwiftUI
import MagicKit

struct VideoView: View {
    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var data: DataProvider
    @EnvironmentObject var playMan: PlayMan

    static var label = "🎬 VideoView::"

    @State var image: Image?
    @State var downloadingPercent: Double = -1

    // MARK: Download

    var isDownloading: Bool { downloadingPercent > 0 && downloadingPercent < 100 }
    var isNotDownloaded: Bool { !isDownloaded }
    var isDownloaded: Bool { downloadingPercent == 100 }

    var asset: PlayAsset
    var label: String { "\(Logger.isMain)\(Self.label)" }
    var updating: DiskFileGroup = .empty

    init(_ asset: PlayAsset) {
        self.asset = asset
    }

    var body: some View {
        VideoPlayer(player: playMan.videoWorker.player)
            .onAppear {
                playMan.play(asset, reason: "OnAppear")
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
