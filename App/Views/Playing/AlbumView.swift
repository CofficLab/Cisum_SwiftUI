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
            image = audio.getCover()
        }
        .onChange(of: audio) { image = audio.getCover() }
    }
}

#Preview("APP") {
    RootView {
        ContentView()
    }
}
