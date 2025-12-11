import AVKit
import MagicCore

import OSLog
import SwiftUI

struct ContentView: View, SuperLog, SuperThread {
    nonisolated static let emoji = "🖥️"
    nonisolated static let verbose = false

    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var p: PluginProvider
    @State private var databaseViewHeight: CGFloat = 300

    // 记录用户调整的窗口的高度
    @State private var height: CGFloat = 0
    @State private var autoResizing = false
    @State private var tab: String = "DB"
    
    /// 当前的 TabView，由插件变化事件驱动更新
    @State private var currentTabView: AnyView?

    var showDB: Bool { app.showDB }
    var controlViewHeightMin = Config.controlViewMinHeight
    var databaseViewHeightMin = Config.databaseViewHeightMin

    init() {
        if Self.verbose {
            os_log("\(Self.i)")
        }
    }

    var body: some View {
        if Self.verbose {
            os_log("\(self.t)📺 开始渲染")
        }
        return GeometryReader { geo in
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
                        // 占位视图，等待插件加载
                        ProgressView("加载中...")
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

    /// 构建 TabView
    ///
    /// 根据当前插件构建 TabView，包含数据库视图和设置视图。
    /// 此方法被事件驱动调用，而非响应式触发。
    ///
    /// - Returns: 包装好的 TabView
    private func buildTabView() -> AnyView {
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

extension ContentView {
    private func increaseHeightToShowDB(_ geo: GeometryProxy, verbose: Bool = true) {
        os_log("\(self.t)增加 Height 以展开数据库视图")
        let space = geo.size.height - controlViewHeightMin

        if space >= databaseViewHeightMin {
            return
        }

        self.autoResizing = true

        if verbose {
            Config.increseHeight(databaseViewHeight - space)
        }
    }

    private func resetHeight(verbose: Bool = false) {
        if verbose {
            os_log("\(self.t)减少 Height 以折叠数据库视图")
        }

        self.autoResizing = true
        Config.setHeight(self.height)
    }
}

// MARK: - Event Handler

extension ContentView {
    /// 当前插件变化时的处理（事件驱动）
    ///
    /// 当 `PluginProvider.current` 变化时触发，主动重新构建 TabView。
    /// 这是一个明确的、事件驱动的更新流程。
    ///
    /// ## 更新流程
    /// 1. 检测到插件变化
    /// 2. 记录日志
    /// 3. 调用 `buildTabView()` 构建新视图
    /// 4. 更新 `currentTabView` 状态
    /// 5. SwiftUI 重新渲染界面
    ///
    /// - Parameters:
    ///   - oldValue: 旧的插件 ID
    ///   - newValue: 新的插件 ID
    func onCurrentPluginChanged(oldValue: String?, newValue: String?) {
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
        let verbose = false
        if verbose {
            os_log("\(self.t)OnAppear")
        }
        
        height = Config.getWindowHeight()
        
        // 初始化 TabView
        if currentTabView == nil {
            if Self.verbose {
                os_log("\(self.t)🚀 初始化 TabView")
            }
            currentTabView = buildTabView()
        }
    }
}

#if os(macOS)
#Preview("App - Large") {
    AppPreview()
        .frame(width: 600, height: 1000)
}

#Preview("App - Small") {
    AppPreview()
        .frame(width: 500, height: 800)
}
#endif

#if os(iOS)
    #Preview("iPhone") {
        AppPreview()
    }
#endif
