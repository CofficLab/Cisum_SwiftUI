import PluginRegistry
import SwiftUI

struct StatusView: View, SuperLog, SuperThread {
    nonisolated static let emoji = "📊"
    nonisolated static let verbose = false

    @EnvironmentObject var p: PluginVM

    var body: some View {
        HStack {
            Spacer()
            let views = p.getStatusViews()
            ForEach(0..<views.count, id: \.self) { index in
                views[index]
            }
        }
    }
}

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}
