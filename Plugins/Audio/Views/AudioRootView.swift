import Foundation
import MagicCore
import MagicPlayMan
import OSLog
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct AudioRootView<Content>: View, SuperLog where Content: View {
    @EnvironmentObject var man: PlayManController
    @EnvironmentObject var m: MagicMessageProvider
    @EnvironmentObject var p: PluginProvider
    @EnvironmentObject var app: AppProvider

    @State private var error: AudioPluginError? = nil
    private var content: Content

    nonisolated static var emoji: String { "📢" }
    let verbose = true
    var container: ModelContainer?
    var disk: URL?
    var repo: AudioRepo?
    var audioProvider: AudioProvider?

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
        guard let container = try? AudioConfigRepo.getContainer() else {
            self.error = AudioPluginError.initialization(reason: "Container 未找到")
            return
        }

        self.container = container

        let storage = Config.getStorageLocation()

        guard let storage = storage else {
            self.error = AudioPluginError.initialization(reason: "Storage 未找到")
            return
        }

        switch storage {
        case .local:
            disk = Config.localDocumentsDir?.appendingFolder(AudioPlugin.dbDirName)
        case .icloud:
            disk = Config.cloudDocumentsDir?.appendingFolder(AudioPlugin.dbDirName)
        case .custom:
            disk = Config.localDocumentsDir?.appendingFolder(AudioPlugin.dbDirName)
        }

        self.disk = try? disk!.createIfNotExist()
        self.container = try? AudioConfigRepo.getContainer()
        self.repo = try? AudioRepo(disk: disk!, reason: "onInit", verbose: false)
        self.audioProvider = AudioProvider(disk: disk!, db: self.repo!)
        self.audioProvider?.updateDisk(disk!)
    }

    var body: some View {
        if let container = self.container {
            ZStack {
                content
            }
            .modelContainer(container)
            .environmentObject(self.audioProvider!)
            .onAppear {
                os_log("\(self.a)")
                self.subscribe()
                self.restorePlaying()
                self.restorePlayMode()
                self.initRepo()
            }
            .onStorageLocationChanged {
                self.m.info("存储位置发生了变化")
            }
            .onDisappear {
                os_log("\(self.t)Disappear")
            }
        }
    }
}

// MARK: 操作

extension AudioRootView {
    private func restorePlayMode() {
        let mode = AudioStateRepo.getPlayMode()
        if let mode = mode {
            self.man.setPlayMode(mode)
        }
    }

    private func initRepo() {
//        let disk = Config.cloudDocumentsDir?.appendingFolder(BookPlugin().dirName)
//        let container = self.container!
//        let reason = self.className
//        Task.detached {
//            let db = BookDB(container, reason: reason)
//            _ = try? BookRepo(disk: disk!, verbose: true, db: db)
//        }
    }

    private func restorePlaying() {
        var assetTarget: URL?
        var timeTarget: TimeInterval = 0
        var liked = false

        Task {
            if let url = AudioStateRepo.getCurrent(), let audio = await self.repo?.find(url) {
                assetTarget = audio
                liked = await self.repo?.isLiked(audio) ?? false

                if let time = AudioStateRepo.getCurrentTime() {
                    timeTarget = time
                }
            } else {
                if verbose {
                    os_log("\(self.t)⚠️⚠️⚠️ No current audio URL, try find first")
                }

                if let first = try? await repo!.getFirst() {
                    assetTarget = first
                    liked = await repo!.isLiked(first)
                } else {
                    os_log("\(self.t)⚠️⚠️⚠️ No audio found")
                }
            }

            if let asset = assetTarget {
                await man.play(url: asset, autoPlay: false)
                await man.seek(time: timeTarget)
                man.setLike(liked)
            }
        }
    }

    private func subscribe() {
        self.man.playMan.subscribe(
            name: self.className,
            onStateChanged: { state in
                if verbose {
                    os_log("\(self.t)🔈 播放状态变为 -> \(state.stateText)")
                }

                if state == .paused {
                    AudioStateRepo.storeCurrentTime(man.playMan.currentTime)
                }
            },
            onPreviousRequested: { asset in
                if verbose {
                    os_log("\(self.t)⏮️ 上一首")
                }

                guard let repo = self.repo else {
                    os_log("\(self.t)⚠️ AudioRepo not found")
                    return
                }

                Task {
                    let prev = try await repo.getPrevOf(asset, verbose: false)

                    if let prev = prev {
                        await man.play(url: prev, autoPlay: self.man.playMan.playing)
                    }
                }
            },
            onNextRequested: { asset in
                if verbose {
                    os_log("\(self.t)⏭️ 下一首")
                }

                guard let repo = self.repo else {
                    os_log("\(self.t)⚠️ AudioDB not found")
                    return
                }

                Task {
                    let next = try await repo.getNextOf(asset, verbose: false)
                    if let next = next {
                        await man.play(url: next, autoPlay: true)
                    }
                }
            },
            onLikeStatusChanged: { url, like in
                if verbose {
                    os_log("\(self.t)❤️ 喜欢状态 -> \(like)")
                }

                guard let repo = self.repo else {
                    os_log("\(self.t)⚠️ AudioDB not found")
                    return
                }
                Task {
                    await repo.like(url, liked: like)
                }
            },
            onPlayModeChanged: { mode in
                if verbose {
                    os_log("\(self.t)播放模式 -> \(mode.shortName)")
                }

                AudioStateRepo.storePlayMode(mode.rawValue)

                Task {
                    let currentURL = man.playMan.currentURL
                    switch mode {
                    case .loop:
                        break
                    case .sequence, .repeatAll:
                        await repo!.sort(currentURL, reason: self.className + ".OnPlayModeChange")
                    case .shuffle:
                        try await repo!.sortRandom(currentURL, reason: self.className + ".OnPlayModeChange", verbose: false)
                    }
                }
            },
            onCurrentURLChanged: { url in
                guard p.current?.label == BookPlugin().label else {
                    return
                }

                if verbose {
                    os_log("\(self.t)CurrentURLChanged -> \(url.shortPath())")
                }

                Task {
                    AudioStateRepo.storeCurrent(url)

                    if url.isNotDownloaded {
                        do {
                            try await url.download()
                            os_log("\(self.t)onPlayAssetUpdate: 开始下载")
                        } catch let e {
                            os_log("\(self.t)onPlayAssetUpdate: \(e.localizedDescription)")
                        }
                    }
                }
            }
        )
    }
}

// MARK: - Preview

#if os(macOS)
    #Preview("App - Large") {
        AppPreview()
            .frame(width: 600, height: 1000)
    }

    #Preview("App - Small") {
        AppPreview()
            .frame(width: 600, height: 600)
    }
#endif

#if os(iOS)
    #Preview("iPhone") {
        AppPreview()
    }
#endif
