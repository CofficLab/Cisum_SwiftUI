import SwiftUI

struct AlbumView: View {
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
            image = audio.cover
        }
        .onChange(of: audio, perform: { audio in
            image = audio.cover
        })
    }
}

#Preview("APP") {
    RootView {
        HomeView(play: false)
    }
}
