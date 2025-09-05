import Foundation
import MagicCore
import MagicPlayMan
import OSLog
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

class BookRepoState: ObservableObject {
    @Published var repo: BookRepo? = nil
    @Published var container: ModelContainer? = nil
    @Published var error: Error? = nil
    @Published var isLoading: Bool = true
}

struct BookRootView<Content>: View, SuperLog where Content: View {
    @EnvironmentObject var man: PlayManController
    @EnvironmentObject var m: MagicMessageProvider
    @EnvironmentObject var p: PluginProvider

    private var content: Content
    @StateObject private var bookRepoState = BookRepoState()

    nonisolated static var emoji: String { "🏓" }
    let verbose = true

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        Group {
            if let error = bookRepoState.error {
                error.makeView()
            } else if bookRepoState.isLoading {
                ProgressView("正在初始化...")
            } else if let container = bookRepoState.container, let repo = bookRepoState.repo {
                ZStack {
                    content
                }
                .modelContainer(container)
                .environmentObject(repo)
                .onAppear {
                    os_log("\(self.a)")
                    self.subscribe()
                    self.restore()
                }
                .onDisappear {
                    os_log("\(self.t)Disappear")
                }
                .onStorageLocationChanged {
                    self.initAll()
                }
                .onPlayManTimeUpdate({ _, _ in
                    self.rememberCurrentTime()
                })
            } else {
                Text("初始化失败")
            }
        }
        .onAppear {
            self.initAll()
        }
    }
}

// MARK: - Setter

extension BookRootView {
    @MainActor private func setBookRepoState(_ repo: BookRepo?, container: ModelContainer?, error: Error? = nil) {
        bookRepoState.repo = repo
        bookRepoState.container = container
        bookRepoState.error = error
        bookRepoState.isLoading = false
    }
}

// MARK: - Action

extension BookRootView {
    private func initAll() {
        os_log("\(self.t)InitAll")
        bookRepoState.isLoading = true
        bookRepoState.error = nil
        
        Task {
            do {
                // 1. 初始化 Container
                let container = try BookConfig.getContainer()
                os_log("🎉Container 初始化成功")
                
                // 2. 获取 Disk
                guard let disk = BookPlugin.getBookDisk() else {
                    await MainActor.run {
                        self.setBookRepoState(nil, container: nil, error: BookPluginError.initialization(reason: "Disk 未找到"))
                    }
                    return
                }
                os_log("🎉Disk 获取成功: \(disk.shortPath())")
                
                // 3. 初始化 BookRepo
                let db = BookDB(container, reason: self.className)
                let repo = try BookRepo(disk: disk, verbose: true, db: db)
                
                await MainActor.run {
                    self.setBookRepoState(repo, container: container)
                    os_log("🎉BookRepo 初始化成功")
                }
            } catch {
                await MainActor.run {
                    self.setBookRepoState(nil, container: nil, error: error)
                    os_log("❌初始化失败: \(error.localizedDescription)")
                }
            }
        }
    }
}

// MARK: - Event Handler

extension BookRootView {
    private func rememberCurrentTime() {
        // 预先在主线程捕获当前时间，避免跨线程访问
        let currentTime = man.playMan.currentTime

        // 在后台线程执行存储操作，避免阻塞UI
        Task.detached(priority: .background) {
            BookSettingRepo.storeCurrentTime(currentTime)
        }
    }

    private func restore() {
        // 提取需要的数据到局部变量，避免在 Task.detached 中捕获 self
        let playMan = self.man
        
        Task.detached(priority: .background) {
            if let url = BookSettingRepo.getCurrent() {
                await playMan.play(url: url, autoPlay: false)

                if let time = BookSettingRepo.getCurrentTime() {
                    await playMan.seek(time: time)
                }
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
