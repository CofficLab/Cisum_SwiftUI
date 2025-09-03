import AVKit
import MagicCore

import OSLog
import SwiftUI

struct ContentView: View, SuperLog, SuperThread {
    nonisolated static let emoji = "🖥️"

    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var p: PluginProvider
    @State private var databaseViewHeight: CGFloat = 300

    // 记录用户调整的窗口的高度
    @State private var height: CGFloat = 0
    @State private var autoResizing = false
    @State private var tab: String = "DB"

    var showDB: Bool { app.showDB }
    var controlViewHeightMin = Config.controlViewMinHeight
    var databaseViewHeightMin = Config.databaseViewHeightMin

    init() {
        let verbose = true
        if verbose {
            os_log("\(Self.i)")
        }
    }

    var body: some View {
        os_log("\(self.t)开始渲染")
        return GeometryReader { geo in
            VStack(spacing: 0) {
                TopView()
                
                ControlView()
                    .frame(height: showDB ? Config.controlViewMinHeight : geo.size.height)

                // 隐藏时高度为 0，避免销毁/重建，同时保持组件常驻
                VStack(spacing: 0) {
                    #if os(macOS)
                        getTabView()
                            .tabViewStyle(GroupedTabViewStyle())
                    #else
                        getTabView()
                    #endif
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
            .onChange(of: showDB) {
                onShowDBChanged(geo)
            }
            .onChange(of: geo.size.height) {
                onGeoHeightChange(geo)
            }
            .onAppear(perform: onAppear)
            .background(Config.background(.teal))
        }
    }

    func getTabView() -> some View {
        TabView(selection: $tab) {
            p.current?.addDBView(reason: self.className)
                .tag("DB")
                .tabItem {
                    Label("仓库", systemImage: "music.note.list")
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

// MARK: 事件处理

extension ContentView {
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
