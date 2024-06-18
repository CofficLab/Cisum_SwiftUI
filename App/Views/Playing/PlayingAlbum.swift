import OSLog
import SwiftUI

struct PlayingAlbum: View {
    @EnvironmentObject var audioManager: PlayManager
    
    var alignTop = false

    var body: some View {
        if alignTop {
            VStack {
                view
                Spacer()
            }
        } else {
            if AppConfig.isiOS {
                view.padding(.horizontal)
            } else {
                view
            }
        }
    }
    
    var view: some View {
        ZStack {
            if let asset = audioManager.asset {
                AlbumView(asset.toAudio(), forPlaying: true)
                    .id(asset.toAudio().id)
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
