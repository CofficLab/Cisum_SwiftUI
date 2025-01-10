import MagicKit
import OSLog
import SwiftUI

struct ContentView: View, @preconcurrency SuperLog, SuperThread {
    static let emoji = "🐮"

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
