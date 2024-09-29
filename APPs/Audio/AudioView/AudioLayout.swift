import AVKit
import MagicKit
import OSLog
import SwiftUI

struct AudioLayout: View, SuperLog, SuperThread {
    let emoji = "🖥️"

    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var l: LayoutProvider
    @State private var databaseViewHeight: CGFloat = 300

    // 记录用户调整的窗口的高度
    @State private var height: CGFloat = 0
    @State private var autoResizing = false
    @State private var tab: String = "DB"

    var showDB: Bool { app.showDB }
    var controlViewHeightMin = Config.controlViewMinHeight
    var databaseViewHeightMin = Config.databaseViewHeightMin

    init() {
        let verbose = false
        if verbose {
            os_log("\(Logger.initLog)AudioLayout")
        }
    }

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                AudioControl()
                    .frame(height: showDB ? Config.controlViewMinHeight : geo.size.height)

                if showDB {
                    if #available(macOS 15.0, *) {
                        #if os(macOS)
                            getTabView()
                                .tabViewStyle(GroupedTabViewStyle())
                        #else
                            getTabView()
                        #endif
                    } else {
                        getTabView()
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
        }
    }

    func getTabView() -> some View {
        TabView(selection: $tab) {
            AudioDB()
                .tag("DB")
                .tabItem {
                    Label("仓库", systemImage: "music.note.list")
                }

            SettingView()
                .tag("Setting")
                .tabItem {
                    Label("设置", systemImage: "gear")
                }

            StoreView()
                .tag("Store")
                .tabItem {
                    Label("订阅", systemImage: "crown")
                }
        }
        .frame(maxHeight: .infinity)
        #if os(macOS)
            .padding(.top, 2)
        #endif
            .background(.background)
    }
}

extension AudioLayout {
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

extension AudioLayout {
    func onGeoHeightChange(_ geo: GeometryProxy) {
        if autoResizing == false {
            // 说明是用户主动调整
            self.height = Config.getWindowHeight()
            // os_log("\(Logger.isMain)\(self.label)Height=\(self.height)")
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
        self.bg.async {
            let verbose = false
            
            if verbose {
                os_log("\(self.t)OnAppear")
            }
            
            if autoResizing == false {
                // 说明是用户主动调整
                self.main.async {
                    self.height = Config.getWindowHeight()
                }
            }
        }
    }

}

#Preview("App") {
    AppPreview()
    #if os(macOS)
        .frame(height: 600)
    #endif
}

#Preview("Layout") {
    LayoutView()
}

#Preview("iPhone 15") {
    LayoutView(device: .iPhone_15)
}

#Preview("iPad") {
    LayoutView(device: .iPad_mini)
}
