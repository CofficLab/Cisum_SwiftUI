import OSLog
import SwiftUI

struct PlayingAlbum: View {
    @EnvironmentObject var audioManager: AudioManager

    var body: some View {
        ZStack {
            if let audio = audioManager.audio {
                AlbumView(audio).scaledToFit().id(audio.id)
            } else {
                Image("PlayingAlbum").resizable().scaledToFit()
            }
        }
    }
}

#Preview("APP") {
    RootView {
        ContentView()
    }
}
