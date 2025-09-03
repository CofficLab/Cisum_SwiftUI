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
    var container: ModelContainer? = nil
    var disk: URL? = nil
    var repo: AudioRepo? = nil
    var audioProvider: AudioProvider? = nil

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
            disk = Config.localDocumentsDir?.appendingFolder(AudioPlugin().dirName)
        case .icloud:
            disk = Config.cloudDocumentsDir?.appendingFolder(AudioPlugin().dirName)
        case .custom:
            disk = Config.localDocumentsDir?.appendingFolder(AudioPlugin().dirName)
        }
        
        self.disk = try? disk!.createIfNotExist()
        self.container = try? AudioConfigRepo.getContainer()
        self.repo = try? AudioRepo(disk: disk!, reason: "onInit", verbose: false)
        self.audioProvider = AudioProvider(disk: disk!, db: self.repo!)
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
                self.restore()
                self.initRepo()
            }
            .onDisappear {
                os_log("\(self.t)Disappear")
            }
        }
    }
}

// MARK: 操作

extension AudioRootView {
    private func initRepo() {
//        let disk = Config.cloudDocumentsDir?.appendingFolder(BookPlugin().dirName)
//        let container = self.container!
//        let reason = self.className
//        Task.detached {
//            let db = BookDB(container, reason: reason)
//            _ = try? BookRepo(disk: disk!, verbose: true, db: db)
//        }
    }
    
    private func restore() {
//        Task {
//            if let url = BookSettingRepo.getCurrent() {
//                await self.man.play(url: url)
//
//                if let time = BookSettingRepo.getCurrentTime() {
//                    await self.man.seek(time: time)
//                }
//            } else {
//                os_log("\(self.t)No current book URL")
//            }
//        }
    }

    private func subscribe() {
        self.man.playMan.subscribe(
            name: self.className,
            onStateChanged: { state in
                if verbose {
                    os_log("\(self.t)🐯 播放状态变为 -> \(state.stateText)")
                }
            },
            onPreviousRequested: { asset in
                if verbose {
                    os_log("\(self.t)⏮️ 上一首")
                }
                if let prev = asset.getPrevFile() {
                    Task {
                        await self.man.play(url: prev)
                    }
                }

            },
            onNextRequested: { asset in
                if verbose {
                    os_log("\(self.t)⏭️ 下一首")
                }
                if let next = asset.getNextFile() {
                    Task {
                        await self.man.play(url: next)
                    }
                }
            },
            onLikeStatusChanged: { _, like in
                if verbose {
                    os_log("\(self.t)❤️ 喜欢状态 -> \(like)")
                }

            },
            onPlayModeChanged: { mode in
                if verbose {
                    os_log("\(self.t)播放模式 -> \(mode.shortName)")
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
                    BookSettingRepo.storeCurrent(url)

                    if url.isNotDownloaded {
                        do {
                            try await url.download()
                            os_log("\(self.t)onPlayAssetUpdate: 开始下载")
                        } catch let e {
                            os_log("\(self.t)onPlayAssetUpdate: \(e.localizedDescription)")

                            assert(false, "BookPlugin: onPlayAssetUpdate: \(e.localizedDescription)")
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
