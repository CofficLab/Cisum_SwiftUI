import SwiftUI

struct AlbumView: View {
    @EnvironmentObject var appManager: AppManager
    @State private var image: Image? = nil

    @Binding var audio: AudioModel

    var body: some View {
        ZStack {
            if let i = image {
                i.resizable().scaledToFit()
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(0.5)
            }
        }
        .onAppear {
            audio.getAudioMeta({ audioMeata in
                image = audioMeata.image
            })
        }
        .onChange(of: audio, perform: { audio in
            audio.getAudioMeta({ audioMeata in
                image = audioMeata.image
            })
        })
    }
}

#Preview("APP") {
    RootView {
        HomeView(play: false)
    }
}
