import SwiftUI

struct NotDownloadedAlbum: View {
    var role: CoverView.Role = .Icon
    
    var body: some View {
        ZStack {
            if role == .Hero {
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
