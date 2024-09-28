import AVKit
import MagicKit
import OSLog
import SwiftUI

struct AudioRoot: View, SuperLog, SuperThread {
    let emoji = "👶"

    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var l: LayoutProvider
    @EnvironmentObject var playMan: PlayMan
    @EnvironmentObject var db: DB

    @State private var mode: PlayMode?

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
            .onReceive(timer, perform: onTimer)
    }
}

// MARK: Functions

extension AudioRoot {
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
    func onAppear() {
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
