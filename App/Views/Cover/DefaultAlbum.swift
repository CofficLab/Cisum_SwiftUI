import SwiftUI

struct DefaultAlbum: View {
    var role: CoverView.Role = .Icon
    
    var body: some View {
        ZStack {
            if role == .Hero {
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
