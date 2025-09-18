import MagicCore
import MagicAsset
import MagicContainer
import SwiftUI

struct LaunchView: View {
    var errorMessage: String? = nil

    var body: some View {
        VStack {
            Spacer()
            MagicLoading(showProgress: false) {
                LogoView(background: .orange.opacity(0.8), rotationSpeed: 0.02, backgroundShape: .circle)
            }
            Spacer()
        }
    }
}

#Preview("LaunchView") {
    LaunchView()
        .frame(width: 300, height: 600)
        .inMagicContainer(.iMac27)
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
