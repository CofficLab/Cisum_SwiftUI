import MagicKit
import OSLog
import SwiftUI

struct AppTabDemo: View, SuperLog, SuperThread {
    nonisolated static let emoji = "📑"
    nonisolated static let verbose = false

    @EnvironmentObject var p: PluginProvider
    @Environment(\.demoMode) var isDemoMode

    var body: some View {
        // 收集所有提供的 Tab 视图，只显示第一个
        let tabViews = p.getTabViews(reason: self.className)

        return VStack {
            if let firstTab = tabViews.last {
                firstTab.view
            }
        }
        .infinite()
    }
}

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}

#Preview("App - Demo") {
    ContentView()
        .inRootView()
        .showTabView()
        .inDemoMode()
        .withDebugBar()
}

#Preview("App Store Album Art") {
    AppStoreAlbumArt()
        .inMagicContainer(.macBook13, scale: 1)
}
