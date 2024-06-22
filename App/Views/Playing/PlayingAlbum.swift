import OSLog
import SwiftUI

struct PlayingAlbum: View {
    @EnvironmentObject var playMan: PlayMan
    
    var alignTop = false

    var body: some View {
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
    
    var view: some View {
        ZStack {
            if let asset = playMan.asset {
                AlbumView(asset, forPlaying: true)
                    .id(asset.url)
            } else {
                DefaultAlbum(forPlaying: true)
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
