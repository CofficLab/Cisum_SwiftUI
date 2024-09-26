import SwiftUI

struct LanuchView: View {
    var errorMessage: String? = nil

    var body: some View {
        GeometryReader { geo in
            Centered {
                Image("PlayingAlbum")
                    .resizable()
                    .frame(width: geo.size.width*0.8)
                    .frame(height: geo.size.width*0.8)
                    .padding()
            }
        }
    }
}

#Preview {
    VStack {
        LanuchView()
    }
}

#Preview {
    AppPreview()
}
