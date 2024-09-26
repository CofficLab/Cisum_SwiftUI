import AVKit
import MagicKit
import OSLog
import SwiftUI

struct AudioLayout: View, SuperLog {
    let emoji = "🖥️"
    static var label = "🖥️ HomeView::"

    @EnvironmentObject var appManager: AppProvider
    @EnvironmentObject var l: LayoutProvider
    @EnvironmentObject var playMan: PlayMan

    @State private var databaseViewHeight: CGFloat = 300

    // 记录用户调整的窗口的高度
    @State private var height: CGFloat = 0
    @State private var autoResizing = false
    @State private var tab: String = "DB"

    var showDB: Bool { appManager.showDB }
    var controlViewHeightMin = Config.controlViewMinHeight
    var databaseViewHeightMin = Config.databaseViewHeightMin
    var verbose = false
    var label: String { "\(Logger.isMain)\(Self.label) " }

    init() {
        if verbose {
            os_log("\(Logger.isMain)\(Self.label)初始化")
        }
    }

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                AudioControl()
                    .frame(height: showDB ? Config.controlViewMinHeight : geo.size.height)

                if showDB {
                    if #available(macOS 15.0, *) {
                        getTabView()
                            .tabViewStyle(GroupedTabViewStyle())
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
                    // os_log("\(Logger.isMain)\(self.label)Height=\(self.height)")
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
                        os_log("\(self.label)Height=\(self.height)")
                    }
                }
            }
            .task {
                self.restore(reason: "BootView")
                Task.detached(
                    priority: .background,
                    operation: {
                        if let url = await playMan.asset?.url, let disk = l.current.getDisk() {
                            await disk.downloadNextBatch(url, reason: "BootView")
                        }
                    })
            }
            .onReceive(NotificationCenter.default.publisher(for: .PlayerEventCurrent)) { notification in
                if let asset = notification.object as? PlayAsset {
                    self.l.current.setCurrent(url: asset.url)
                }
            }
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

    // MARK: 恢复上次播放的

    func restore(reason: String, verbose: Bool = true) {
        if verbose {
            os_log("\(self.t)👻👻👻 Restore because of \(reason)")
        }

        var db: DB = DB(Config.getContainer, reason: "dataManager")

        if let url = l.current.getCurrent() {
            self.playMan.prepare(PlayAsset(url: url))
            return
        }

        if let disk = l.current.getDisk() {
            self.playMan.prepare(db.firstAudio()?.toPlayAsset())
        }

//        playMan.mode = PlayMode(rawValue: Config.currentMode) ?? playMan.mode

//        Task {
//            let currentURL = await dbSynced.getSceneCurrent(data.appScene, reason: "Restore")
//
//            if let url = currentURL {
//                if verbose {
//                    os_log("\(t)上次播放 -> \(url.lastPathComponent)")
//                }
//
//                playMan.prepare(PlayAsset(url: url))
//            } else {
//                if verbose {
//                    os_log("\(t)无上次播放的音频，尝试播放第一个(\(data.disk.name))")
//                }
//
//                playMan.prepare(data.first())
//            }
//        }
    }
}

extension AudioLayout {
    private func increseHeightToShowDB(_ geo: GeometryProxy, verbose: Bool = true) {
        os_log("\(self.label)增加 Height 以展开数据库视图")
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
            os_log("\(self.label)减少 Height 以折叠数据库视图")
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
