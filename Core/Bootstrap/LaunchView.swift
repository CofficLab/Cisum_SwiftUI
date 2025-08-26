import MagicCore
import MagicAsset
import SwiftUI

struct LaunchView: View {
    var errorMessage: String? = nil

    var body: some View {
        GeometryReader { geo in
            MagicLoading()
                .magicTitle(MagicApp.getAppName())
                .magicCustomView {
                    Image.makeCoffeeReelIcon()
                        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 32, height: 32)))
                        .frame(width: min(geo.size.width * 0.8, geo.size.height * 0.8))
                        .frame(height: min(geo.size.width * 0.8, geo.size.height * 0.8))
                        .padding()
                }
        }
    }
}

#Preview("App - Large") {
    AppPreview()
        .frame(width: 600, height: 1000)
}

#Preview("App - Small") {
    AppPreview()
        .frame(width: 500, height: 800)
}

#if os(iOS)
#Preview("iPhone") {
    AppPreview()
}
#endif
