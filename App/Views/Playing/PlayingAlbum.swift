import OSLog
import SwiftUI

struct PlayingAlbum: View {
    @EnvironmentObject var playMan: AudioMan
    
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
