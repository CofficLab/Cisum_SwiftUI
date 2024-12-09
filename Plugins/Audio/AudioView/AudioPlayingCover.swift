import MagicKit
import OSLog
import SwiftUI

struct AudioPlayingCover: View, SuperLog {
    @EnvironmentObject var playMan: PlayMan

    @State var asset: PlayAsset?

    let emoji = "🥇"
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
        .onAppear(perform: onAppear)
        .onReceive(NotificationCenter.default.publisher(for: .PlayManStateChange), perform: onPlayStateChange)
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

// MARK: Event Handler

extension AudioPlayingCover {
    func onPlayStateChange(_ notification: Notification) {
        let asset = playMan.asset
        
        if asset != self.asset {
            os_log("\(self.t)PlayAssetChange: \(playMan.state.des)")
            withAnimation {
                self.asset = asset
            }
        }
    }

    func onAppear() {
        self.asset = playMan.asset
    }
}

#Preview("APP") {
    AppPreview()
}

#Preview("Layout") {
    LayoutView()
}
