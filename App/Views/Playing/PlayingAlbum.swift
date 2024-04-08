import OSLog
import SwiftUI

struct PlayingAlbum: View {
    @EnvironmentObject var audioManager: AudioManager
    
    @State var image: Image? = nil
    
    var audio: Audio? { audioManager.audio }
    var fileManager = FileManager.default
    var withBackground = false
    var rotate = true

    var body: some View {
        ZStack {
            if let audio = audio {
                AlbumView(audio)
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
