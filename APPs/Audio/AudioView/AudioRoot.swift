import AVKit
import MagicKit
import Network
import OSLog
import SwiftData
import SwiftUI

struct AudioRoot: View, SuperLog, SuperThread {
    let emoji = "👶"

    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var l: LayoutProvider
    @EnvironmentObject var playMan: PlayMan
    @EnvironmentObject var db: DB

    @State private var mode: PlayMode?
    @State var networkOK = true
    @State var copyJob: AudioCopyJob?

    @Query(sort: \Audio.order, animation: .default) var audios: [Audio]
    @Query(animation: .default) var copyTasks: [CopyTask]

    var disk: (any Disk)? { l.current.getDisk() }

    let timer = Timer
        .publish(every: 10, on: .main, in: .common)
        .autoconnect()

    init() {
        let verbose = false
        if verbose {
            os_log("\(Logger.initLog)AudioRoot")
        }
    }

    var body: some View {
        AudioLayout()
            .onAppear(perform: onAppear)
            .onReceive(NotificationCenter.default.publisher(for: .PlayManStateChange), perform: onPlayStateChange)
            .onReceive(NotificationCenter.default.publisher(for: .AudioAppDidBoot), perform: onAudioAppDidBoot)
            .onReceive(NotificationCenter.default.publisher(for: .PlayManPlay), perform: onPlay)
            .onReceive(NotificationCenter.default.publisher(for: .PlayManNext), perform: onPlayNext)
            .onReceive(NotificationCenter.default.publisher(for: .PlayManPrev), perform: onPlayPrev)
            .onReceive(NotificationCenter.default.publisher(for: .PlayManRandomNext), perform: onPlayRandomNext)
            .onReceive(NotificationCenter.default.publisher(for: .PlayManModeChange), perform: onPlayModeChange)
            .onReceive(NotificationCenter.default.publisher(for: .dbSyncing), perform: onDBSyncing)
            .onReceive(NotificationCenter.default.publisher(for: .CopyFiles), perform: onCopyFiles)
            .onReceive(timer, perform: onTimer)
            .onChange(of: audios.count, onChangeOfAudiosCount)
            .onChange(of: self.disk?.root, onChangeOfDisk)
    }
}

// MARK: Functions

extension AudioRoot {
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

    func restore(reason: String, verbose: Bool = false) {
        self.bg.async {
            if verbose {
                os_log("\(self.t)Restore because of \(reason)")
            }

            let db: DB = DB(Config.getContainer, reason: "dataManager")

            if let url = l.current.getCurrent() {
                self.playMan.prepare(PlayAsset(url: url), reason: "AudioRoot.Restore")
            } else if (l.current.getDisk()) != nil {
                self.playMan.prepare(db.firstAudio()?.toPlayAsset(), reason: "AudioRoot.Restore")
            }
        }
    }

    private func setCurrent(url: URL) {
        self.bg.async {
            self.l.current.setCurrent(url: url)
        }
    }

    func downloadNextBatch(url: URL?, count: Int, reason: String) {
        self.bg.async {
            let verbose = false
            if verbose {
                os_log("\(self.t)DownloadNextBatch(\(count))")

                Task {
                    if let url = url, let disk = await l.current.getDisk() {
                        var currentIndex = 0
                        var currentURL: URL = url

                        while currentIndex < count {
                            disk.download(currentURL, reason: "downloadNext 🐛 \(reason)")

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

//        if appScene == .Music {
//
//        } else {
//            var currentIndex = 0
//            var currentURL: URL = url
//
//            while currentIndex < count {
//                disk.download(currentURL, reason: "downloadNext 🐛 \(reason)")
//
//                currentIndex = currentIndex + 1
//
//                if let next = disk.next(currentURL) {
//                    currentURL = next.url
//                } else {
//                    break
//                }
//            }
//        }
    }
}

// MARK: 事件处理

extension AudioRoot {
    func onChangeOfDisk() {
        if let disk = disk {
            self.copyJob = AudioCopyJob(db: db, disk: disk)
        }
    }

    func onDBSyncing(_ notification: Notification) {
        let verbose = false
        let files = notification.userInfo?["files"] as? [DiskFile] ?? []

        self.bg.async {
            if verbose {
                os_log("\(self.t)DBSyncing -> \(files.count)")
            }

            if let playError = app.error as? PlayManError,
               case .NotDownloaded = playError {
                let assetURL = playMan.state.getAsset()?.url

                if let assetURL = assetURL {
                    for file in files {
                        if assetURL == file.url, file.isDownloaded {
                            if verbose {
                                os_log("\(self.t)DBSyncing -> 下载完成 -> \(file.url.lastPathComponent)")
                            }
                            app.clearError()
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

    func onChangeOfAudiosCount() {
        Task {
            if playMan.asset == nil, let first = db.firstAudio()?.toPlayAsset() {
                os_log("\(self.t)准备第一个")
                playMan.prepare(first, reason: "count changed")
            }
        }

        if audios.count == 0 {
            playMan.prepare(nil, reason: "count changed")
        }
    }

    func onAppear() {
        if audios.count == 0 {
            app.showDBView()
        }

        checkNetworkStatus()

        self.bg.async {
            let verbose = true

            if verbose {
                os_log("\(self.t)OnAppear")
            }
        }
    }

    func onTimer(_ timer: Date) {
        let asset = playMan.asset
        self.downloadNextBatch(url: asset?.url, count: 4, reason: "AudioRoot确保下一个准备好")
    }

    func onPlayNext(_ notification: Notification) {
        let asset = notification.userInfo?["asset"] as? PlayAsset
        self.bg.async {
            if let asset = asset {
                let next = db.getNextOf(asset.url)?.toPlayAsset()
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
                let prev = db.getPrevOf(asset.url)?.toPlayAsset()
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
                let next = db.getNextOf(asset.url)?.toPlayAsset()
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
        let state = notification.userInfo?["state"] as? PlayState

        self.bg.async {
            let verbose = false
            if verbose {
                os_log("\(self.t)OnPlayStateChange")
            }

            if let state = state {
                if let asset = state.getPlayingAsset() {
                    self.setCurrent(url: asset.url)
                }

                if let e = state.getError() {
                    os_log("\(self.t)播放状态错误 -> \(e.localizedDescription)")

                    if let playManError = e as? PlayManError,
                       case .NotDownloaded = playManError,
                       let disk = disk,
                       let asset = state.getAsset() {
                        disk.download(asset.url, reason: "PlayManError.NotDownloaded")
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
                l.current.setCurrentPlayMode(mode: mode)
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
