import OSLog
import SwiftUI

struct PlayingAlbum: View {
    @EnvironmentObject var audioManager: AudioManager
    
    var alignTop = false

    var body: some View {
        if alignTop {
            VStack {
                view
                Spacer()
            }
        } else {
            view
        }
    }
    
    var view: some View {
        ZStack {
            if let audio = audioManager.audio {
                AlbumView(audio, forPlaying: true)
                    .id(audio.id)
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
