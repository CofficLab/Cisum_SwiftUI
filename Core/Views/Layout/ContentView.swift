import AVKit
import MagicKit

import OSLog
import SwiftUI

struct ContentView: View, SuperLog, SuperThread {
    nonisolated static let emoji = "🖥️"
    nonisolated static let verbose = false

    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var p: PluginProvider
    @Environment(\.demoMode) var isDemoMode
    @State private var databaseViewHeight: CGFloat = 300

    // 记录用户调整的窗口的高度
    @State private var height: CGFloat = 0
    @State private var autoResizing = false
    @State private var tab: String = "DB"

    /// 当前的 TabView，由插件变化事件驱动更新
    @State private var currentTabView: AnyView?

    var showDB: Bool { app.showDB || isDemoMode }
    var controlViewHeightMin = Config.controlViewMinHeight
    var databaseViewHeightMin = Config.databaseViewHeightMin

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                ControlView()
                    .frame(height: showDB ? Config.controlViewMinHeight : geo.size.height)

                // 隐藏时高度为 0，避免销毁/重建，同时保持组件常驻
                VStack(spacing: 0) {
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
                            // 占位视图，等待插件加载
                            ProgressView("加载中...")
                        }
                    }
                }
                .frame(height: showDB ? (geo.size.height - Config.controlViewMinHeight) : 0)
                .opacity(showDB ? 1 : 0)
                .allowsHitTesting(showDB)
                .accessibilityHidden(!showDB)

                HStack {
                    Spacer()
                    ForEach(Array(p.getStatusViews().enumerated()), id: \.offset) { _, view in
                        view
                    }
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .onChange(of: showDB) {
                onShowDBChanged(geo)
            }
            .onChange(of: geo.size.height) {
                onGeoHeightChange(geo)
            }
            .onChange(of: p.current?.id) { oldValue, newValue in
                onCurrentPluginChanged(oldValue: oldValue, newValue: newValue)
            }
            .onAppear(perform: onAppear)
            .background(Config.background(.teal))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Action

extension ContentView {
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

// MARK: - Setter

extension ContentView {
    func increaseHeightToShowDB(_ geo: GeometryProxy) {
        let space = geo.size.height - controlViewHeightMin

        if space >= databaseViewHeightMin {
            return
        }

        self.autoResizing = true
    }

    func resetHeight(verbose: Bool = false) {
        self.autoResizing = true
        Config.setHeight(self.height)
    }
}

// MARK: - Event Handler

extension ContentView {
    /// 当前插件变化时的处理（事件驱动）
    func onCurrentPluginChanged(oldValue: String?, newValue: String?) {
        currentTabView = buildTabView()
    }

    func onGeoHeightChange(_ geo: GeometryProxy) {
        if autoResizing == false {
            // 说明是用户主动调整
            self.height = Config.getWindowHeight()
            // os_log("\(Logger.isMain)\(self.t)Height=\(self.height)")
        }

        autoResizing = false

        if geo.size.height <= controlViewHeightMin + 20 {
            app.closeDBView()
        }
    }

    func onShowDBChanged(_ geo: GeometryProxy) {
        // 高度被自动修改过了，重置
        if !showDB && geo.size.height != self.height {
            resetHeight()
            return
        }

        // 高度不足，自动调整以展示数据库
        if showDB && geo.size.height - controlViewHeightMin <= databaseViewHeightMin {
            self.increaseHeightToShowDB(geo)
            return
        }
    }

    func onAppear() {
        height = Config.getWindowHeight()

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
