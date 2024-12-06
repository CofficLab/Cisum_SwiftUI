import AVKit
import MagicKit
import Network
import OSLog
import SwiftData
import SwiftUI

struct BookRoot: View, SuperLog, SuperThread, SuperFamily {
    let emoji = "📚"
    let title = "有声书模式"
    let dirName = "audios_book"
    let iconName = "books.vertical"
    let description = "适用于听有声书的场景"
    let keyOfCurrentURL = "currentBookURL"
    let poster: any View = BookPoster()

    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var root: FamalyProvider
    @EnvironmentObject var data: DataProvider
    @EnvironmentObject var play: PlayMan

    @State private var mode: PlayMode?
    @State var networkOK = true
    @State var copyJob: BookCopyJob?
    @State var disk: (any SuperDisk)?

    @Query(sort: \Book.order, animation: .default) var books: [Book]
    @Query(animation: .default) var copyTasks: [CopyTask]

    var db: DB { data.db }

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
        BookLayout()
            .task(priority: .low) { runJobs() }
            .onAppear(perform: onAppear)
            .onDisappear(perform: onDisappear)
            .onReceive(NotificationCenter.default.publisher(for: .PlayManStateChange), perform: onPlayStateChange)
            .onReceive(NotificationCenter.default.publisher(for: .PlayManPlay), perform: onPlay)
            .onReceive(NotificationCenter.default.publisher(for: .PlayManNext), perform: onPlayNext)
            .onReceive(NotificationCenter.default.publisher(for: .PlayManPrev), perform: onPlayPrev)
            .onReceive(NotificationCenter.default.publisher(for: .PlayManRandomNext), perform: onPlayRandomNext)
            .onReceive(NotificationCenter.default.publisher(for: .dbSyncing), perform: onDBSyncing)
            .onReceive(NotificationCenter.default.publisher(for: .CopyFiles), perform: onCopyFiles)
            .onReceive(timer, perform: onTimer)
            .onChange(of: books.count, onChangeOfBooksCount)
    }
}

// MARK: Actions

extension BookRoot {
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

        if verbose {
            os_log("\(self.t)GetCurrent")
        }

        if let urlString = UserDefaults.standard.string(forKey: keyOfCurrentURL) {
            let url = URL(string: urlString)

            if verbose {
                os_log("  🎉 \(url?.lastPathComponent ?? "")")
            }

            return url
        }
        
        if verbose {
            os_log("  ➡️ No current book URL found")
        }
        
        return nil
    }

    func getDisk() -> (any SuperDisk)? {
        self.disk
    }
    
    func watchDisk(reason: String) {
        guard var disk = disk else {
            return
        }

        disk.onUpdated = { items in
            Task {
                await DB(Config.getContainer, reason: "DataManager.WatchDisk").bookSync(items)
            }
        }

        Task {
            await disk.watch(reason: reason)
        }
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

    func restore(reason: String, verbose: Bool = true) {
        self.bg.async {
            if verbose {
                os_log("\(self.t)Restore Book 🐛 \(reason)")
            }

            let db: DB = DB(Config.getContainer, reason: "BookRoot")

            if let url = getCurrent() {
                self.play.prepare(PlayAsset(url: url), reason: "BookRoot.Restore")
            } else if (root.current.getDisk()) != nil {
                self.play.prepare(db.firstAudio()?.toPlayAsset(), reason: "BookRoot.Restore")
            }
        }
    }

    func downloadNextBatch(url: URL?, count: Int, reason: String) {
        self.bg.async {
            let verbose = false
            if verbose {
                os_log("\(self.t)DownloadNextBatch(\(count))")

                Task {
                    if let url = url, let disk = await root.current.getDisk() {
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
            
            self.restore(reason: "OnAppear")
            self.copyJob = BookCopyJob(db: db, disk: disk!)
            BookUpdateCoverJob(container: data.container).run()
            
            checkNetworkStatus()
        }
    }
}

// MARK: Events Handler

extension BookRoot {
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
                if case .NotDownloaded = playError, let assetURL = play.state.getAsset()?.url {
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

                if case .Downloading = playError, let assetURL = play.state.getAsset()?.url {
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

    func onChangeOfBooksCount() {
        Task {
            if play.asset == nil, let first = db.firstBook()?.toPlayAsset() {
                os_log("\(self.t)准备第一个")
                play.prepare(first, reason: "count changed")
            }
        }

        if books.count == 0 {
            play.prepare(nil, reason: "count changed")
        }
    }

    func onAppear() {
        if books.count == 0 {
            app.showDBView()
        }

        checkNetworkStatus()

        self.bg.async {
            let verbose = false

            if verbose {
                os_log("\(self.t)OnAppear")
            }

            self.disk = DiskiCloud.make(self.dirName, verbose: true)
            self.watchDisk(reason: "BookRoot.OnAppear")
        }
    }

    func onDisappear() {
        self.bg.async {
            let verbose = true
            if verbose {
                os_log("\(self.t)OnDisappear")
            }
            
            self.disk?.stopWatch(reason: "BookRoot.OnDisappear")
        }
    }

    func onTimer(_ timer: Date) {
        let asset = play.asset
        self.downloadNextBatch(url: asset?.url, count: 4, reason: "AudioRoot确保下一个准备好")
    }

    func onPlayNext(_ notification: Notification) {
        let verbose = true
        let asset = notification.userInfo?["asset"] as? PlayAsset
        self.bg.async {
            if let asset = asset {
                let next = asset.url.getNextFile()

                if verbose {
                    os_log("\(self.t)播放下一个 -> \(next?.lastPathComponent ?? "")")
                }

                if let next = next {
                    try? self.play.play(PlayAsset(url: next), reason: "onPlayNext")
                }
            }
        }
    }

    func onPlayPrev(_ notification: Notification) {
        let verbose = false
        let asset = notification.userInfo?["asset"] as? PlayAsset
        self.bg.async {
            if let asset = asset {
                let prev = asset.url.getPrevFile()

                if verbose {
                    os_log("\(self.t)播放上一个 -> \(prev?.lastPathComponent ?? "")")
                }

                if let prev = prev {
                    try? self.play.play(PlayAsset(url: prev), reason: "onPlayPrev")
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
                    try? self.play.play(next, reason: "onPlayNext")
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
                os_log("\(self.t)OnPlayStateChange -> \(state?.des ?? "nil")")
            }

            if let state = state {
                if let asset = state.getPlayingAsset() {
                    self.setCurrent(url: asset.url)
                }

                if let e = state.getError() {
                    if verbose {
                        os_log("\(self.t)播放状态错误 -> \(e.localizedDescription)")
                    }

                    if let playManError = e as? PlayManError, case .NotDownloaded = playManError {
                        guard let disk = disk else {
                            os_log(.error, "\(self.t)Disk is nil")
                            return
                        }

                        guard let asset = state.getAsset() else {
                            os_log(.error, "\(self.t)Asset is nil")
                            return
                        }

                        if verbose {
                            os_log("\(self.t)自动下载")
                        }

                        Task {
                            try? await disk.download(asset.url, reason: "PlayManError.NotDownloaded")
                        }
                    }
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
