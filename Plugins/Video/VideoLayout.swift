import AVKit
import OSLog
import SwiftUI
import MagicKit
import MagicUI

struct VideoLayout: View, SuperLog {
    static var emoji = "🖥️"

    @EnvironmentObject var appManager: AppProvider

    @State private var databaseViewHeight: CGFloat = 300

    // 记录用户调整的窗口的高度
    @State private var height: CGFloat = 0
    @State private var autoResizing = false
    @State private var tab: String = "DB"

    var showDB: Bool { appManager.showDB }
    var controlViewHeightMin = Config.controlViewMinHeight
    var databaseViewHeightMin = Config.databaseViewHeightMin
    var verbose = false

    init() {
        if verbose {
            os_log("\(Self.i)")
        }
    }

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                VideoControl()
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
                // 高度被自动修改过了，重置
                if !showDB && geo.size.height != self.height {
                    resetHeight()
                    return
                }

                // 高度不足，自动调整以展示数据库
                if showDB && geo.size.height - controlViewHeightMin <= databaseViewHeightMin {
                    increseHeightToShowDB(geo)
                    return
                }
            }
            .onChange(of: geo.size.height) {
                if autoResizing == false {
                    // 说明是用户主动调整
                    self.height = Config.getWindowHeight()
                    // os_log("\(Logger.isMain)\(self.t)Height=\(self.height)")
                }

                autoResizing = false

                if geo.size.height <= controlViewHeightMin + 20 {
                    appManager.closeDBView()
                }
            }
            .onAppear {
                if autoResizing == false {
                    // 说明是用户主动调整
                    self.height = Config.getWindowHeight()
                    if verbose {
                        os_log("\(self.t)Height=\(self.height)")
                    }
                }
            }
        }
    }

    func getTabView() -> some View {
        TabView(selection: $tab) {
            VideoDB()
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

            if Config.debug {
                DBViewNavigation()
                    .tag("Testing")
                    .tabItem {
                        Label("测试", systemImage: "testtube.2")
                    }
            }
        }
        .frame(maxHeight: .infinity)
        #if os(macOS)
            .padding(.top, 2)
        #endif
            .background(.background)
    }
}

extension VideoLayout {
    private func increseHeightToShowDB(_ geo: GeometryProxy, verbose: Bool = true) {
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
