import AVKit
import MagicKit
import OSLog
import SwiftUI

struct AudioLayout: View, SuperLog, SuperThread {
    let emoji = "🖥️"

    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var l: LayoutProvider
    @EnvironmentObject var playMan: PlayMan
    @EnvironmentObject var dbLocal: DB
    @State private var databaseViewHeight: CGFloat = 300

    // 记录用户调整的窗口的高度
    @State private var height: CGFloat = 0
    @State private var autoResizing = false
    @State private var tab: String = "DB"

    @State private var mode: PlayMode?

    var showDB: Bool { app.showDB }
    var controlViewHeightMin = Config.controlViewMinHeight
    var databaseViewHeightMin = Config.databaseViewHeightMin
    var verbose = false

    init() {
        if verbose {
            os_log("\(Logger.initLog)初始化")
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
            .onChange(of: geo.size.height) {
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
            .onAppear(perform: onAppear)
            .onReceive(NotificationCenter.default.publisher(for: .PlayManStateChange), perform: onPlayStateChange)
            .onReceive(NotificationCenter.default.publisher(for: .AudioAppDidBoot), perform: onAudioAppDidBoot)
            .onReceive(NotificationCenter.default.publisher(for: .PlayManPlay), perform: onPlay)
            .onReceive(NotificationCenter.default.publisher(for: .PlayManNext), perform: onPlayNext)
            .onReceive(NotificationCenter.default.publisher(for: .PlayManPrev), perform: onPlayPrev)
            .onReceive(NotificationCenter.default.publisher(for: .PlayManRandomNext), perform: onPlayRandomNext)
            .onReceive(NotificationCenter.default.publisher(for: .PlayManModeChange), perform: onPlayModeChange)
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

    // MARK: 恢复上次播放的

    func restore(reason: String, verbose: Bool = false) {
        self.bg.async {
            if verbose {
                os_log("\(self.t)Restore because of \(reason)")
            }

            let db: DB = DB(Config.getContainer, reason: "dataManager")

            if let url = l.current.getCurrent() {
                self.playMan.prepare(PlayAsset(url: url), reason: "Restore")
            } else if (l.current.getDisk()) != nil {
                self.playMan.prepare(db.firstAudio()?.toPlayAsset(), reason: "Restore")
            }
        }
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

    private func setCurrent(url: URL) {
        self.bg.async {
            self.l.current.setCurrent(url: url)
        }
    }
}

// MARK: 事件处理

extension AudioLayout {
    func onAppear() {
        if autoResizing == false {
            // 说明是用户主动调整
            self.height = Config.getWindowHeight()
            if verbose {
                os_log("\(self.t)Height=\(self.height)")
            }
        }

        self.mode = l.current.getCurrentPlayMode()
        if let mode = mode {
            playMan.setMode(mode)
        }
    }

    func onPlayNext(_ notification: Notification) {
        let asset = notification.userInfo?["asset"] as? PlayAsset
        self.bg.async {
            if let asset = asset {
                let next = dbLocal.getNextOf(asset.url)?.toPlayAsset()
                os_log("\(self.t)播放下一个 -> \(next?.url.lastPathComponent ?? "")")

                if let next = next {
                    self.playMan.play(next, reason: "onPlayNext")
                }
            }
        }
    }

    func onPlayPrev(_ notification: Notification) {
        let asset = notification.userInfo?["asset"] as? PlayAsset
        self.bg.async {
            if let asset = asset {
                let prev = dbLocal.getPrevOf(asset.url)?.toPlayAsset()
                os_log("\(self.t)播放上一个 -> \(prev?.url.lastPathComponent ?? "")")

                if let prev = prev {
                    self.playMan.play(prev, reason: "onPlayPrev")
                }
            }
        }
    }

    func onPlayRandomNext(_ notification: Notification) {
        let asset = notification.userInfo?["asset"] as? PlayAsset
        self.bg.async {
            if let asset = asset {
                let next = dbLocal.getNextOf(asset.url)?.toPlayAsset()
                os_log("\(self.t)随机播放下一个 -> \(next?.url.lastPathComponent ?? "")")

                if let next = next {
                    self.playMan.play(next, reason: "onPlayNext")
                }
            }
        }
    }

    func onAudioAppDidBoot(_ notification: Notification) {
        self.restore(reason: "AudioAppDidBoot")
        if let url = playMan.asset?.url, let disk = l.current.getDisk() {
            disk.downloadNextBatch(url, reason: "BootView")
        }
    }

    func onPlay(_ notification: Notification) {
        if let asset = notification.object as? PlayAsset {
            self.setCurrent(url: asset.url)
        }
    }

    func onPlayStateChange(_ notification: Notification) {
        let verbose = false
        if verbose {
            os_log("\(self.t)OnPlayStateChange")
        }

        if let state = notification.userInfo?["state"] as? PlayState {
            if let asset = state.getPlayingAsset() {
                self.setCurrent(url: asset.url)
            }
        }
    }

    func onPlayModeChange(_ notification: Notification) {
        let mode = notification.userInfo?["mode"] as? PlayMode
        let state = notification.userInfo?["state"] as? PlayState
        
        self.bg.async {
            let verbose = false

            if verbose {
                os_log("\(self.t)OnPlayModeChange -> \(mode?.rawValue ?? "nil")")
                os_log("  ➡️ State -> \(state?.des ?? "nil")")
                os_log("  ➡️ Mode -> \(mode?.rawValue ?? "nil")")
            }

            if mode == self.mode {
                return
            }

            if let mode = mode {
                l.current.setCurrentPlayMode(mode: mode)
                self.mode = mode
            }

            switch mode {
            case .Order:
                dbLocal.sort(state?.getAsset()?.url, reason: "onPlayModeChange")
            case .Loop:
                dbLocal.sticky(state?.getAsset()?.url, reason: "onPlayModeChange")
            case .Random:
                dbLocal.sortRandom(state?.getAsset()?.url, reason: "onPlayModeChange")
            case .none:
                os_log("\(self.t)播放模式 -> 未知")
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
