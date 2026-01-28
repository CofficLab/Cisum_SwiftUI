import MagicKit
import OSLog
import SwiftUI

struct AppTabDemo: View, SuperLog, SuperThread {
    nonisolated static let emoji = "📑"
    nonisolated static let verbose = false

    @EnvironmentObject var p: PluginProvider
    @Environment(\.demoMode) var isDemoMode

    @State private var tab: String = "DB"
    @State private var currentTabView: AnyView?

    var body: some View {
            buildTabView()
            #if os(macOS)
                .tabViewStyle(GroupedTabViewStyle())
            #endif
    }
}

// MARK: - Builder

extension AppTabDemo {
    /// 构建 TabView
    func buildTabView() -> AnyView {
        // 收集所有提供的 Tab 视图及标签
        let tabViews = p.plugins.compactMap { plugin in
            plugin.addTabView(reason: self.className, currentSceneName: p.currentSceneName)
        }

        let tabView = TabView(selection: $tab) {
            ForEach(Array(tabViews.enumerated()), id: \.offset) { index, item in
                item.view
                    .tag("TAB\(index)")
                    .tabItem {
                        Label(item.label, systemImage: "music.note.list")
                    }
            }

            SettingView()
                .tag("Setting")
                .tabItem {
                    Label("设置", systemImage: "gear")
                }
        }
        .frame(maxHeight: .infinity)
        #if os(macOS)
            .padding(.top, 2)
        #endif
            .background(.background)

        return AnyView(tabView)
    }
}

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}

#Preview("App Store Album Art") {
    AppStoreAlbumArt()
        .inMagicContainer(.macBook13, scale: 1)
}
