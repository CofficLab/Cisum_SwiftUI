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

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}

#Preview("App") {
    LayoutView()
}
