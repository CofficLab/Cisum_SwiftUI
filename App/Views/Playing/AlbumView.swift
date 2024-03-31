import SwiftUI

struct AlbumView: View {
    @Binding var audio: Audio

    var body: some View {
        VStack {
            Spacer()
            audio.getCover().resizable().scaledToFit()
            Spacer()
        }
    }
}

#Preview("APP") {
    RootView {
        ContentView()
    }
}
