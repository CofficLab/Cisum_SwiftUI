import SwiftUI

struct AlbumView: View {
    @Binding var audio: Audio

    var body: some View {
        ZStack {
            audio.getCover().resizable().scaledToFit()
        }
    }
}

#Preview("APP") {
    RootView {
        ContentView()
    }
}
