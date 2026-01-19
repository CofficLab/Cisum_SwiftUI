import MagicKit
import SwiftUI

struct StatusView: View, SuperLog, SuperThread {
    nonisolated static let emoji = "📊"
    nonisolated static let verbose = false

    @EnvironmentObject var p: PluginProvider

    var body: some View {
        HStack {
            Spacer()
            ForEach(Array(p.getStatusViews().enumerated()), id: \.offset) { _, view in
                view
            }
        }
    }
}

// MARK: - Preview

#if os(macOS)
    #Preview("App - Large") {
        ContentView()
            .inRootView()
            .frame(width: 600, height: 1000)
    }

    #Preview("App - Small") {
        ContentView()
            .inRootView()
            .frame(width: 600, height: 600)
    }

    #Preview("Demo Mode") {
        ContentView()
            .inRootView()
            .inDemoMode()
            .frame(width: 600, height: 1000)
    }
#endif

#if os(iOS)
    #Preview("iPhone") {
        ContentView()
            .inRootView()
    }
#endif
