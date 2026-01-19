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
        .onChange(of: p.current?.id, onChangeOfCurrentPlugin)
        .onAppear(perform: onAppear)
    }
}

// MARK: - Builder

extension AppTabView {
    /// 构建 TabView
    func buildTabView() -> AnyView {
        if Self.verbose {
            os_log("\(self.t)🏗️ buildTabView() 构建新的 TabView - 当前插件: \(p.current?.id ?? "nil")")
        }

        let currentId = p.current?.id

        // 收集所有提供的 Tab 视图及标签
        let tabViews = p.plugins.compactMap { plugin in
            plugin.addTabView(reason: self.className, currentPluginId: currentId)
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
    /// 当前插件变化时的处理（事件驱动）
    func onChangeOfCurrentPlugin(oldValue: String?, newValue: String?) {
        if Self.verbose {
            os_log("\(self.t)🔄 插件变化事件: \(oldValue ?? "nil") -> \(newValue ?? "nil")")
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
