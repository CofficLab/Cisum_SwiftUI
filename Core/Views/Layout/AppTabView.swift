import MagicKit
import OSLog
import SwiftUI

struct AppTabView: View, SuperLog, SuperThread {
    nonisolated static let emoji = "📑"
    nonisolated static let verbose = false

    @EnvironmentObject var p: PluginProvider
    @Environment(\.demoMode) var isDemoMode

    @State private var tab: String = "DB"
    @State private var currentTabView: AnyView?

    var body: some View {
        Group {
            if let tabView = currentTabView {
                #if os(macOS)
                    tabView
                        .tabViewStyle(GroupedTabViewStyle())
                #else
                    tabView
                #endif
            } else {
                // Demo 模式下直接显示视图，不显示加载过程
                if isDemoMode {
                    buildTabView()
                    #if os(macOS)
                        .tabViewStyle(GroupedTabViewStyle())
                    #endif
                } else {
                    ProgressView("加载中...")
                }
            }
        }
        .onChange(of: p.currentSceneName, onChangeOfCurrentScene)
        .onAppear(perform: onAppear)
    }
}

// MARK: - Builder

extension AppTabView {
    /// 构建 TabView
    func buildTabView() -> AnyView {
        if Self.verbose {
            os_log("\(self.t)🏗️ buildTabView() 构建新的 TabView - 当前场景: \(p.currentSceneName ?? "nil")")
        }

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

// MARK: - Event Handler

extension AppTabView {
    /// 当前场景变化时的处理（事件驱动）
    func onChangeOfCurrentScene(oldValue: String?, newValue: String?) {
        if Self.verbose {
            os_log("\(self.t)🔄 场景变化事件: \(oldValue ?? "nil") -> \(newValue ?? "nil")")
            os_log("\(self.t)📱 开始重新构建 TabView...")
        }

        // 事件驱动：主动更新视图
        currentTabView = buildTabView()

        if Self.verbose {
            os_log("\(self.t)✅ TabView 已更新完成")
        }
    }

    func onAppear() {
        if Self.verbose {
            os_log("\(self.t)🚀 初始化 TabView")
        }

        // 初始化 TabView
        if currentTabView == nil {
            currentTabView = buildTabView()
        }
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
