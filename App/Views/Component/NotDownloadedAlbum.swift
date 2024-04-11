import SwiftUI

struct NotDownloadedAlbum: View {
    var forPlaying = false
    
    var body: some View {
        ZStack {
            if forPlaying {
                HStack {
                    Spacer()
                    Image(systemName: "arrow.down.circle.dotted")
                        .resizable()
                        .scaledToFit()
                    Spacer()
                }
            } else {
                Image(systemName: "arrow.down.circle.dotted")
                    .resizable()
                    .scaledToFit()
            }
        }
    }
}

#Preview {
    NotDownloadedAlbum()
}
