import AVKit
import MagicKit
import Network
import OSLog
import SwiftData
import SwiftUI

struct AudioRoot: View, SuperLog, SuperThread, SuperFamily {
    let emoji = "🎶"
    let dirName = "audios"
    let iconName = "music.note.list"
    let title = "歌曲模式"
    let description: String = "作为歌曲仓库，只关注文件，文件夹将被忽略"
    let keyOfCurrentURL = "currentAudioURL"
    let keyOfCurrentPlayMode = "currentAudioPlayMode"
    let poster: any View = AudioPoster()
    let timer = Timer
        .publish(every: 10, on: .main, in: .common)
        .autoconnect()
    
    var db: DB { d.db }

    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var playMan: PlayMan
    @EnvironmentObject var d: DataProvider
    @EnvironmentObject var p: PluginProvider

    @State private var mode: PlayMode?
    @State var networkOK = true
    @State var copyJob: AudioCopyJob?
    @State var disk: (any SuperDisk)?

    @Query(sort: \Audio.order, animation: .default) var audios: [Audio]
    @Query(animation: .default) var copyTasks: [CopyTask]

    init() {
        let verbose = false
        if verbose {
            os_log("\(Logger.initLog)AudioRoot")
        }
    }

    var body: some View {
        MainView()
            .task(priority: .low) { runJobs() }
            .onAppear(perform: onAppear)
            .onDisappear(perform: onDisappear)
            .onReceive(NotificationCenter.default.publisher(for: .PlayManStateChange), perform: onPlayStateChange)
            .onReceive(NotificationCenter.default.publisher(for: .PlayManPlay), perform: onPlay)
            .onReceive(NotificationCenter.default.publisher(for: .PlayManNext), perform: onPlayNext)
            .onReceive(NotificationCenter.default.publisher(for: .PlayManPrev), perform: onPlayPrev)
            .onReceive(NotificationCenter.default.publisher(for: .PlayManRandomNext), perform: onPlayRandomNext)
            .onReceive(NotificationCenter.default.publisher(for: .PlayManModeChange), perform: onPlayModeChange)
            .onReceive(NotificationCenter.default.publisher(for: .dbSyncing), perform: onDBSyncing)
            .onReceive(NotificationCenter.default.publisher(for: .CopyFiles), perform: onCopyFiles)
            .onReceive(timer, perform: onTimer)
    }
}

// MARK: Actions

extension AudioRoot {
    func getDisk() -> (any SuperDisk)? {
        return disk
    }

    func watchDisk(reason: String) {
        guard var disk = disk else {
            return
        }

        disk.onUpdated = { items in
            Task {
                await DB(Config.getContainer, reason: "AudioRoot.WatchDisk").sync(items)
            }
        }

        Task {
            await disk.watch(reason: reason)
        }
    }

    func setCurrent(url: URL) {
        let verbose = false
        if verbose {
            os_log("\(self.t)SetCurrent: \(url.lastPathComponent)")
        }

        // 将当前的url存储下来
        UserDefaults.standard.set(url.absoluteString, forKey: keyOfCurrentURL)

        // 通过iCloud key-value同步
        NSUbiquitousKeyValueStore.default.set(url.absoluteString, forKey: keyOfCurrentURL)
        NSUbiquitousKeyValueStore.default.synchronize()
    }

    func getCurrent() -> URL? {
        let verbose = false
        
        if let urlString = UserDefaults.standard.string(forKey: keyOfCurrentURL) {
            let url = URL(string: urlString)
            if verbose {
                os_log("\(self.t)GetCurrent, Found: \(url?.lastPathComponent ?? "")")
            }
            
            return url
        }
        
        if verbose {
            os_log("\(self.t)GetCurrent, Not Found")
        }


        return nil
    }

    func setCurrentPlayMode(mode: PlayMode) {
        // 将当前的播放模式存储到UserDefaults
        UserDefaults.standard.set(mode.rawValue, forKey: keyOfCurrentPlayMode)

        // 通过iCloud key-value同步
        NSUbiquitousKeyValueStore.default.set(mode.rawValue, forKey: keyOfCurrentPlayMode)
        NSUbiquitousKeyValueStore.default.synchronize()

        let verbose = false
        if verbose {
            os_log("\(self.t)setCurrentPlayMode: \(mode.rawValue)")
        }
    }

    func getCurrentPlayMode() -> PlayMode? {
        if let modeRawValue = UserDefaults.standard.string(forKey: keyOfCurrentPlayMode) {
            return PlayMode(rawValue: modeRawValue)
        }
        return nil
    }

    func checkNetworkStatus() {
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                if path.status == .satisfied {
                    self.networkOK = true
                } else {
                    self.networkOK = false
                }
            }
        }

        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
    }

    func downloadNextBatch(url: URL?, count: Int, reason: String) {
        self.bg.async {
            let verbose = false
            if verbose {
                os_log("\(self.t)DownloadNextBatch(\(count))")

                Task {
                    if let url = url, let disk = await p.current?.getDisk() {
                        var currentIndex = 0
                        var currentURL: URL = url

                        while currentIndex < count {
                            try await disk.download(currentURL, reason: "downloadNext 🐛 \(reason)")

                            currentIndex = currentIndex + 1

                            if let next = await db.nextOf(currentURL) {
                                currentURL = next.url
                            } else {
                                break
                            }
                        }
                    }
                }
            }
        }
    }
    
    func runJobs() {
        self.bg.async {
            let verbose = true
            
            if verbose {
                os_log("\(self.t)RunJobs")
            }
            
            self.copyJob = AudioCopyJob(db: db, disk: disk!)
            
            checkNetworkStatus()
        }
    }
}

// MARK: Events Handler

extension AudioRoot {
    func onDBSyncing(_ notification: Notification) {
        let verbose = false
        guard let group = notification.userInfo?["group"] as? DiskFileGroup else {
            return
        }

        self.bg.async {
            if verbose {
                os_log("\(self.t)DBSyncing -> \(group.count)")
            }

            if let playError = app.error as? PlayManError {
                if case .NotDownloaded = playError, let assetURL = playMan.state.getAsset()?.url {
                    for file in group.files {
                        if assetURL == file.url, file.isDownloaded {
                            if verbose {
                                os_log("\(self.t)DBSyncing -> 下载完成 -> \(file.url.lastPathComponent)")
                            }
                            app.clearError()

                            break
                        }

                        if assetURL == file.url, file.isDownloading, file.isDownloading {
                            app.setPlayManError(.Downloading)

                            break
                        }
                    }
                }

                if case .Downloading = playError, let assetURL = playMan.state.getAsset()?.url {
                    for file in group.files {
                        if assetURL == file.url, file.isDownloaded {
                            if verbose {
                                os_log("\(self.t)DBSyncing -> 下载完成 -> \(file.url.lastPathComponent)")
                            }
                            app.clearError()

                            break
                        }
                    }
                }
            }
        }
    }

    func onCopyFiles(_ notification: Notification) {
        if let job = copyJob, let urls = notification.userInfo?["urls"] as? [URL] {
            job.append(urls)
        }
    }

    func onAppear() {
        if audios.count == 0 {
            app.showDBView()
        }

        self.bg.async {
            let verbose = false

            if verbose {
                os_log("\(self.t)OnAppear")
            }
            
            self.disk = DiskiCloud.make(self.dirName, verbose: true)
            self.watchDisk(reason: "AudioApp.Boot")
        }
    }

    func onDisappear() {
        self.bg.async {
            let verbose = true
            if verbose {
                os_log("\(self.t)OnDisappear")
            }
            
            self.disk?.stopWatch(reason: "OnDisappear")
        }
    }

    func onTimer(_ timer: Date) {
        let asset = playMan.asset
        self.downloadNextBatch(url: asset?.url, count: 4, reason: "AudioRoot确保下一个准备好")
    }

    func onPlayNext(_ notification: Notification) {
        let verbose = false
        let asset = notification.userInfo?["asset"] as? PlayAsset
        self.bg.async {
            if let asset = asset {
                let next = db.getNextOf(asset.url)?.toPlayAsset()

                if verbose {
                    os_log("\(self.t)播放下一个 -> \(next?.url.lastPathComponent ?? "")")
                }

                if let next = next {
                    try? self.playMan.play(next, reason: "onPlayNext", verbose: true)
                }
            }
        }
    }

    func onPlayPrev(_ notification: Notification) {
        let verbose = false
        let asset = notification.userInfo?["asset"] as? PlayAsset
        self.bg.async {
            if let asset = asset {
                let prev = db.getPrevOf(asset.url)?.toPlayAsset()

                if verbose {
                    os_log("\(self.t)播放上一个 -> \(prev?.url.lastPathComponent ?? "")")
                }

                if let prev = prev {
                    try? self.playMan.play(prev, reason: "onPlayPrev", verbose: true)
                }
            }
        }
    }

    func onPlayRandomNext(_ notification: Notification) {
        let asset = notification.userInfo?["asset"] as? PlayAsset
        self.bg.async {
            if let asset = asset {
                let next = db.getNextOf(asset.url)?.toPlayAsset()
                os_log("\(self.t)随机播放下一个 -> \(next?.url.lastPathComponent ?? "")")

                if let next = next {
                    try? self.playMan.play(next, reason: "onPlayNext", verbose: true)
                }
            }
        }
    }
    
    func onPlay(_ notification: Notification) {
        if let asset = notification.object as? PlayAsset {
            self.setCurrent(url: asset.url)
        }
    }

    func onPlayStateChange(_ notification: Notification) {
        let state = notification.userInfo?["state"] as? PlayState

        self.bg.async {
            let verbose = false
            if verbose {
                os_log("\(self.t)OnPlayStateChange: \(playMan.state.des)")
            }

            if let state = state {
                if let asset = state.getPlayingAsset() {
                    self.setCurrent(url: asset.url)
                }

                if let e = state.getError() {
                    if verbose {
                        os_log("\(self.t)播放状态错误 -> \(e.localizedDescription)")
                    }

                    if let playManError = e as? PlayManError,
                       case .NotDownloaded = playManError,
                       let disk = disk,
                       let asset = state.getAsset() {
                        Task {
                            try? await disk.download(asset.url, reason: "PlayManError.NotDownloaded")
                        }
                    }
                }
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
                setCurrentPlayMode(mode: mode)
                self.mode = mode
            }

            switch mode {
            case .Order:
                Task {
                    await db.sort(state?.getAsset()?.url, reason: "onPlayModeChange")
                }
            case .Loop:
                Task {
                    await db.sticky(state?.getAsset()?.url, reason: "onPlayModeChange")
                }
            case .Random:
                Task {
                    await db.sortRandom(state?.getAsset()?.url, reason: "onPlayModeChange")
                }
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
