import MagicKit
import SwiftUI
import OSLog

struct LaunchDoneView: View, SuperLog {
    nonisolated static let verbose = true
    nonisolated static let emoji = "🚀"

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
    LaunchDoneView()
        .frame(width: 300, height: 600)
        .inMagicContainer(.iMac27)
}

#Preview("LaunchView - Dark") {
    LaunchDoneView()
        .frame(width: 300, height: 600)
        .inMagicContainer(.iMac27)
        .preferredColorScheme(.dark)
}

#if os(macOS)
#Preview("App - Large") {
    AppPreview()
        .frame(width: 600, height: 1000)
}

#Preview("App - Small") {
    AppPreview()
        .frame(width: 600, height: 600)
}
#endif

#if os(iOS)
#Preview("iPhone") {
    AppPreview()
}
#endif
