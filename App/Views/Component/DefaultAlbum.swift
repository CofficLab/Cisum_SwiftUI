import SwiftUI

struct DefaultAlbum: View {
    var forPlaying = false
    
    var body: some View {
        ZStack {
            if forPlaying {
                HStack {
                    Spacer()
                    Image("PlayingAlbum")
                        .resizable()
                        .scaledToFit()
                        .rotationEffect(.degrees(-90))
                    Spacer()
                }
            } else {
                Image("DefaultAlbum")
                    .resizable()
                    .scaledToFit()
                    .rotationEffect(.degrees(-90))
            }
        }
    }
}

#Preview {
    DefaultAlbum()
}
