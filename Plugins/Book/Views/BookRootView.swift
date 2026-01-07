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
    nonisolated static var emoji: String { "🏓" }
    nonisolated static var verbose: Bool { false }

    @EnvironmentObject var man: PlayManController
    @EnvironmentObject var m: MagicMessageProvider
    @EnvironmentObject var p: PluginProvider

    private var content: Content
    @StateObject private var bookRepoState = BookRepoState()

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
                    if Self.verbose {
                        os_log("\(self.a)")
                    }
                    self.subscribe()
                    self.restore()
                }
                .onDisappear {
                    if Self.verbose {
                        os_log("\(self.t)Disappear")
                    }
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

// MARK: - Action

extension BookRootView {
    private func initAll() {
        if Self.verbose {
            os_log("\(self.t)InitAll")
        }
        bookRepoState.isLoading = true
        bookRepoState.error = nil

        Task {
            do {
                // 1. 初始化 Container
                let container = try BookConfig.getContainer()
                if Self.verbose {
                    os_log("\(self.t)🎉 Container 初始化成功")
                }

                // 2. 获取 Disk
                guard let disk = BookPlugin.getBookDisk() else {
                    await MainActor.run {
                        self.setBookRepoState(nil, container: nil, error: BookPluginError.initialization(reason: "Disk 未找到"))
                    }
                    return
                }
                if Self.verbose {
                    os_log("\(self.t)🎉 Disk 获取成功: \(disk.shortPath())")
                }

                // 3. 初始化 BookRepo
                let db = BookDB(container, reason: self.className)
                let repo = try BookRepo(disk: disk, db: db)

                await MainActor.run {
                    self.setBookRepoState(repo, container: container)
                    if Self.verbose {
                        os_log("\(self.t)🎉 BookRepo 初始化成功")
                    }
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

// MARK: - Setter

extension BookRootView {
    @MainActor private func setBookRepoState(_ repo: BookRepo?, container: ModelContainer?, error: Error? = nil) {
        bookRepoState.repo = repo
        bookRepoState.container = container
        bookRepoState.error = error
        bookRepoState.isLoading = false
    }
}

// MARK: - Event Handler

extension BookRootView {
    private func rememberCurrentTime() {
        // 预先在主线程捕获当前时间，避免跨线程访问
        let currentTime = man.playMan.currentTime
        let currentURL = man.playMan.currentURL

        // 在后台线程执行存储操作，避免阻塞UI
        Task.detached(priority: .background) {
            // 保存全局时间状态
            BookSettingRepo.storeCurrentTime(currentTime)

            // 如果有当前URL，也保存到书籍状态
            if let currentURL = currentURL {
                Task { @MainActor in
                    await self.saveBookState(currentURL: currentURL)
                }
            }
        }
    }

    private func saveBookState(currentURL: URL) async {
        // 找到当前URL所属的书籍
        guard let bookURL = await findBookForURL(currentURL) else {
            if Self.verbose {
                os_log("\(self.t)⚠️ 无法找到 \(currentURL.lastPathComponent) 所属的书籍")
            }
            return
        }

        // 获取当前播放时间
        let currentTime = man.playMan.currentTime

        // 更新书籍状态（保存当前章节和时间）
        if Self.verbose {
            os_log("\(self.t)💾 保存书籍状态: \(bookURL.lastPathComponent) -> \(currentURL.lastPathComponent) @ \(currentTime)s")
        }

        // 通过 BookDB 更新 BookState
        guard let container = bookRepoState.container else {
            os_log(.error, "\(self.t)⚠️ 无法访问数据库容器")
            return
        }

        // 这里需要异步调用 BookDB 的方法
        Task {
            let db = BookDB(container, reason: "saveBookState")
            await db.updateBookCurrent(bookURL, currentURL: currentURL, time: currentTime)
        }
    }

    private func findBookForURL(_ url: URL) async -> URL? {
        guard let repo = self.bookRepoState.repo else {
            return nil
        }

        // 从仓库中查找包含此URL的书籍
        let books = await repo.getAll(reason: "findBookForURL")
        for book in books {
            if book.url == url || book.url.getChildren().contains(url) {
                return book.url
            }
        }

        return nil
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
            onPreviousRequested: { asset in
                if Self.verbose {
                    os_log("\(self.t)⏮️ 上一首")
                }
                if let prev = asset.getPrevFile() {
                    Task {
                        await self.man.play(url: prev)
                    }
                }

            },
            onNextRequested: { asset in
                if Self.verbose {
                    os_log("\(self.t)⏭️ 下一首")
                }
                if let next = asset.getNextFile() {
                    Task {
                        await self.man.play(url: next)
                    }
                }
            },
            onLikeStatusChanged: { _, like in
                if Self.verbose {
                    os_log("\(self.t)❤️ 喜欢状态 -> \(like)")
                }

            },
            onPlayModeChanged: { mode in
                if Self.verbose {
                    os_log("\(self.t)播放模式 -> \(mode.shortName)")
                }

            },
            onCurrentURLChanged: { url in
                guard p.current?.label == BookPlugin().label else {
                    return
                }

                if Self.verbose {
                    os_log("\(self.t)CurrentURLChanged -> \(url.shortPath())")
                }

                Task {
                    // 保存全局状态（用于应用启动恢复）
                    BookSettingRepo.storeCurrent(url)

                    // 保存每本书的状态（用于每本书独立进度）
                    await self.saveBookState(currentURL: url)

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
