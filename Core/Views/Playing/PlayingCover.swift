import MagicKit
import MagicUI
import OSLog
import SwiftUI

struct PlayingCover: View, SuperLog {
    @EnvironmentObject var man: PlayMan

    private var asset: PlayAsset? { man.asset }

    static let emoji = "🥇"
    var alignTop = false

    var body: some View {
        ZStack {
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
    }

    var view: some View {
        ZStack {
            if let asset = asset {
                CoverView(asset, role: .Hero)
                    .id(asset.url)
            } else {
                DefaultAlbum(role: .Hero)
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
