import AVKit
import OSLog
import SwiftUI
import MagicKit
import MagicUI
import MagicUI
import MagicPlayMan

struct VideoView: View, SuperLog {
    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var playMan: MagicPlayMan

    static var emoji = "🎬"

    @State var image: Image?
    @State var downloadingPercent: Double = -1

    // MARK: Download

    var isDownloading: Bool { downloadingPercent > 0 && downloadingPercent < 100 }
    var isNotDownloaded: Bool { !isDownloaded }
    var isDownloaded: Bool { downloadingPercent == 100 }

    var asset: PlayAsset
    var updating: [DiskFile] = []

    init(_ asset: PlayAsset) {
        self.asset = asset
    }

    var body: some View {
        EmptyView()
    }
}

#Preview("APP") {
    AppPreview()
        .frame(height: 800)
}

#Preview("ProgressView") {
    PictureView.makeProgressView()
        .frame(width: 300, height: 300)
        .background(MagicBackground.aurora)
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
    }.background(MagicBackground.aurora)
}
