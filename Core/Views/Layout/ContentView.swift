import MagicCore
import OSLog
import SwiftUI

struct ContentView: View, MagicCore.SuperLog, SuperThread {
    nonisolated static let emoji = "🐮"

    var body: some View {
        VStack(spacing: 0) {
            if Config.isNotDesktop {
                TopView()
            }

            MainView()
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

