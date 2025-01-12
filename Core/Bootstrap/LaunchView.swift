import MagicAsset
import SwiftUI

struct LaunchView: View {
    var errorMessage: String? = nil

    var body: some View {
        GeometryReader { geo in
            VStack {
                Spacer()

                HStack {
                    Spacer()
                    Image.makeCoffeeReelIcon()
                        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 32, height: 32)))
                        .frame(width: min(geo.size.width * 0.8, geo.size.height * 0.8))
                        .frame(height: min(geo.size.width * 0.8, geo.size.height * 0.8))
                        .padding()
                    Spacer()
                }
                .frame(height: min(geo.size.width * 0.8, geo.size.height * 0.8))

                Text(MagicApp.getAppName())
                    .font(.largeTitle)

                Spacer()
            }
        }
    }
}

#Preview {
    VStack {
        LaunchView()
    }
}

#Preview {
    AppPreview()
}
