import Foundation
import MagicCore
import MagicPlayMan
import OSLog
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct BookRootView<Content>: View, SuperLog where Content: View {
    @EnvironmentObject var man: PlayManController
    @EnvironmentObject var m: MagicMessageProvider
    @EnvironmentObject var p: PluginProvider

    @State private var error: Error? = nil
    private var content: Content
    @State private var repo: BookRepo? = nil

    nonisolated static var emoji: String { "🏓" }
    let verbose = true
    var container: ModelContainer?

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
        guard let container = try? BookConfig.getContainer() else {
            self.error = BookPluginError.initialization(reason: "Container 未找到")
            return
        }

        self.container = container
    }

    var body: some View {
        ZStack {
            if let container = self.container {
                ZStack {
                    content
                }
                .modelContainer(container)
                .onAppear {
                    os_log("\(self.a)")
                    self.subscribe()
                    self.restore()
                    self.initRepo()
                }
                .onDisappear {
                    os_log("\(self.t)Disappear")
                }
            } else if let error = self.error {
                error.makeView()
            }
        }
        .onStorageLocationChanged {
            self.initRepo()
        }
    }
}

// MARK: Setter

extension BookRootView {
    @MainActor private func setError(_ e: Error?) {
        self.error = e
    }
}

// MARK: 操作

extension BookRootView {
    private func initRepo() {
        os_log("\(self.t)InitRepo")
        let disk = BookPlugin.getBookDisk()
        let container = self.container!
        let reason = self.className
        Task {
            let db = BookDB(container, reason: reason)
            do {
                self.repo = try BookRepo(disk: disk!, verbose: true, db: db)
            } catch {
                self.setError(error)
            }
        }
    }
    
    private func restore() {
        Task.detached(priority: .background) {
            if let url = BookSettingRepo.getCurrent() {
                await self.man.play(url: url)

                if let time = BookSettingRepo.getCurrentTime() {
                    await self.man.seek(time: time)
                }
            } else {
                os_log("\(self.t)No current book URL")
            }
        }
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
