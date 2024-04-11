import OSLog
import SwiftUI

struct PlayingAlbum: View {
    @EnvironmentObject var audioManager: AudioManager

    var body: some View {
        ZStack {
            if let audio = audioManager.audio {
                AlbumView(audio, forPlaying: true).id(audio.id)
            } else {
                DefaultAlbum(forPlaying: true)
            }
        }
    }
}

#Preview("APP") {
    RootView {
        ContentView()
    }.modelContainer(AppConfig.getContainer())
}
