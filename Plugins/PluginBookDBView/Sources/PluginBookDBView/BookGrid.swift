import MagicKit
import MagicPlayMan
import OSLog
import PluginAudio
import PluginBook
import SwiftData
import SwiftUI

struct BookGrid: View, SuperLog, SuperThread, SuperEvent {
    nonisolated static let emoji = "📖"
    nonisolated static let verbose = false

    @Environment(\.bookDBViewDependencies) private var dependencies
    @EnvironmentObject var man: MagicPlayMan
    @EnvironmentObject var repo: BookRepo

    @State var selection: AudioModel? = nil
    @State var syncingTotal: Int = 0
    @State var syncingCurrent: Int = 0
    
    /// 当前选中的书籍 URL
    @State private var selectedBookURL: URL? = nil
    
    /// 书籍集合列表数组（文件夹类型的书籍）
    @State private var books: [BookDTO] = []
    
    /// 是否正在加载
    @State private var isLoading: Bool = true
    
    /// 是否正在同步数据
    @State private var isSyncing: Bool = false
    
    /// 防抖更新任务
    @State private var updateBooksDebounceTask: Task<Void, Never>? = nil

    /// 书籍总数
    var total: Int { books.count }

    /// 查找书籍状态
    private func findBookState(_ bookURL: URL, in container: ModelContainer) async -> BookState? {
        let context = ModelContext(container)
        do {
            let descriptor = BookState.descriptorOf(bookURL)
            let result = try context.fetch(descriptor)
            return result.first
        } catch {
            if Self.verbose {
                os_log("\(self.t)⚠️ 查询书籍状态失败: \(error.localizedDescription)")
            }
            return nil
        }
    }

    /// 是否显示提示信息
    var showTips: Bool {
        false
    }

    var body: some View {
        if Self.verbose {
            os_log("\(self.t)📺 开始渲染")
        }
        return Group {
            if isLoading {
                BookDBTips(variant: .loading)
            } else if total == 0 {
                BookDBTips(variant: .empty)
            } else {
                VStack(spacing: 0) {
                    HStack {
                        Text("共 \(total)", tableName: "Book-DBView", bundle: .module)
                        Spacer()
                        if isSyncing {
                            HStack(spacing: 6) {
                                ProgressView()
                                    .controlSize(.small)
                                Text("正在读取仓库", tableName: "Book-DBView", bundle: .module)
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 5)
                    
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.adaptive(minimum: 150), spacing: 12),
                        ], alignment: .center, spacing: 16, pinnedViews: [.sectionHeaders]) {
                            ForEach(books) { item in
                                BookTile(url: item.url, title: item.bookTitle, childCount: item.childCount)
                                    .overlay(
                                        // 高亮边框
                                        Rectangle()
                                            .stroke(
                                                selectedBookURL == item.url ? Color.accentColor : Color.clear,
                                                lineWidth: selectedBookURL == item.url ? 3 : 0
                                            )
                                    )
                                    .animation(.easeInOut(duration: 0.2), value: selectedBookURL)
                                    .onTapGesture {
                                        handleBookTap(book: item)
                                    }
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .onAppear(perform: handleOnAppear)
        .onPlayManAssetChanged(handleAssetChanged)
        .onBookDBDeleted(perform: handleBookDBDeleted)
        .onBookDBSynced(perform: handleBookDBSynced)
        .onBookDBSortDone(perform: handleBookDBSortDone)
        .onBookDBUpdated(perform: handleBookDBUpdated)
        .onBookDBSyncing(perform: handleBookDBSyncing)
        .onDisappear(perform: handleOnDisappear)
    }
}

// MARK: - Action

extension BookGrid {
    /// 更新书籍列表
    ///
    /// 从数据仓库异步获取所有书籍数据并更新界面。
    /// 只获取集合类型的书籍（文件夹），按顺序排序。
    /// 使用后台优先级执行，避免阻塞主线程。
    private func updateBooks() {
        let currentRepo = self.repo
        Task.detached(priority: .background) {
            if Self.verbose {
                os_log("\(self.t)🔄 开始获取书籍列表")
            }
            
            let books = await currentRepo.getAll(reason: self.className)
            
            if Self.verbose {
                os_log("\(self.t)✅ 获取到 \(books.count) 本书籍")
            }

            await self.setBooks(books)
        }
    }

    /// 调度防抖更新
    ///
    /// 使用防抖机制延迟更新书籍列表，避免频繁刷新。
    /// 如果在延迟期间再次调用，会取消之前的任务并重新开始计时。
    ///
    /// - Parameter seconds: 延迟秒数，默认为 0.25 秒
    @MainActor
    private func scheduleUpdateBooksDebounced(delay seconds: Double = 0.25) {
        if Self.verbose {
            os_log("\(self.t)⏱️ 调度防抖更新，延迟 \(seconds) 秒")
        }
        
        updateBooksDebounceTask?.cancel()
        updateBooksDebounceTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: UInt64(seconds * 1000000000))
            guard !Task.isCancelled else { return }
            self.updateBooks()
        }
    }
    
    /// 更新选中的书籍
    ///
    /// 根据给定的音频 URL，查找并高亮显示包含该音频的书籍。
    /// 如果 URL 是书籍本身或书籍的子文件，都会被识别并选中。
    ///
    /// - Parameter url: 要查找的音频文件 URL
    private func updateSelectedBook(for url: URL) {
        if Self.verbose {
            os_log("\(self.t)🔍 查找包含音频的书籍: \(url.lastPathComponent)")
        }
        
        // 查找包含该URL的书籍
        for book in books {
            if book.url == url || book.url.getChildren().contains(url) {
                if Self.verbose {
                    os_log("\(self.t)✅ 找到书籍: \(book.bookTitle)")
                }
                selectedBookURL = book.url
                return
            }
        }
        
        if Self.verbose {
            os_log("\(self.t)⚠️ 未找到对应的书籍")
        }
        selectedBookURL = nil
    }

    private func playableChildren(for book: BookDTO) -> [URL] {
        book.url.getChildren()
            .filter { url in
                !url.isFolder
                    && FileManager.default.fileExists(atPath: url.path)
                    && BookPluginInfo.supportedExtensions.contains(url.pathExtension.lowercased())
            }
            .sorted {
                $0.lastPathComponent.localizedStandardCompare($1.lastPathComponent) == .orderedAscending
            }
    }

    private func isPlayableSavedURL(_ savedURL: URL, in book: BookDTO, playableChildren: [URL]) -> Bool {
        if book.url == savedURL {
            return FileManager.default.fileExists(atPath: savedURL.path)
                && BookPluginInfo.supportedExtensions.contains(savedURL.pathExtension.lowercased())
        }

        return playableChildren.contains(savedURL)
    }

    private func play(_ url: URL, at time: TimeInterval?, reason: String) async {
        await man.play(url, autoPlay: false, reason: reason)

        if let time {
            await man.seek(time: time, reason: reason)
        }
    }
    
    /// 播放书籍
    ///
    /// 点击书籍时触发播放操作。优先使用保存的播放进度继续播放，
    /// 如果没有保存状态，则从头开始播放。
    ///
    /// - Parameter book: 要播放的书籍 DTO
    private func playBook(_ book: BookDTO) async {
        if Self.verbose {
            os_log("\(self.t)▶️ 准备播放书籍: \(book.bookTitle)")
        }

        let playableChildren = playableChildren(for: book)
        let reason = self.className

        // 首先尝试从 BookState 恢复该书的进度
        do {
            let container = try BookConfig.getContainer(dbRootURL: dependencies.dbRoot)
            if let bookState = await findBookState(book.url, in: container),
               let savedURL = bookState.currentURL,
               let savedTime = bookState.time,
               isPlayableSavedURL(savedURL, in: book, playableChildren: playableChildren) {
                // 该书有保存的进度，继续播放
                if Self.verbose {
                    os_log("\(self.t)📖 继续播放书籍进度: \(savedURL.lastPathComponent) @ \(savedTime)s")
                }
                await play(savedURL, at: savedTime, reason: reason)
                return
            }
        } catch {
            if Self.verbose {
                os_log("\(self.t)⚠️ 无法访问书籍数据库: \(error.localizedDescription)")
            }
        }

        // 其次检查全局状态是否属于这本书
        if let savedURL = BookSettingRepo.getCurrent(),
           let savedTime = BookSettingRepo.getCurrentTime(),
           isPlayableSavedURL(savedURL, in: book, playableChildren: playableChildren) {
            // 当前保存的URL属于这本书，继续播放
            if Self.verbose {
                os_log("\(self.t)📖 从全局状态继续播放: \(savedURL.lastPathComponent) @ \(savedTime)s")
            }
            await play(savedURL, at: savedTime, reason: reason)
            return
        }

        // 没有保存状态，从头开始播放
        if let first = playableChildren.first {
            if Self.verbose {
                os_log("\(self.t)🎵 从头播放第一个子文件: \(first.lastPathComponent)")
            }
            await man.play(first, reason: reason)
        } else {
            guard FileManager.default.fileExists(atPath: book.url.path),
                  BookPluginInfo.supportedExtensions.contains(book.url.pathExtension.lowercased()) else {
                if Self.verbose {
                    os_log("\(self.t)⚠️ 没有可播放章节: \(book.bookTitle)")
                }
                return
            }

            await man.play(book.url, reason: reason)
        }
    }
}

// MARK: - Setter

extension BookGrid {
    /// 设置书籍列表
    ///
    /// 更新书籍列表并结束加载状态。
    /// 如果当前选中的书籍不在新列表中，会自动清除选中状态。
    ///
    /// - Parameter newValue: 新的书籍 DTO 列表
    @MainActor
    private func setBooks(_ newValue: [BookDTO]) {
        if Self.verbose {
            os_log("\(self.t)📋 设置书籍列表，数量: \(newValue.count)")
        }
        
        books = newValue
        self.setIsLoading(false)

        // 数据加载完成后再根据当前播放项恢复选中状态，避免空列表阶段丢失高亮。
        if let currentAsset = man.asset {
            updateSelectedBook(for: currentAsset)
        } else if let currentSelection = selectedBookURL, !newValue.contains(where: { $0.url == currentSelection }) {
            if Self.verbose {
                os_log("\(self.t)⚠️ 当前选中的书籍不在列表中，清除选中状态")
            }
            selectedBookURL = nil
        }
    }

    /// 设置加载状态
    ///
    /// - Parameter newValue: 是否正在加载
    private func setIsLoading(_ newValue: Bool) {
        if Self.verbose {
            os_log("\(self.t)⏳ 加载状态: \(newValue ? "加载中" : "完成")")
        }
        isLoading = newValue
    }

    /// 设置同步状态
    ///
    /// - Parameter newValue: 是否正在同步
    private func setIsSyncing(_ newValue: Bool) {
        if Self.verbose {
            os_log("\(self.t)🔄 同步状态: \(newValue ? "同步中" : "完成")")
        }
        isSyncing = newValue
    }
}

// MARK: - Event Handler

extension BookGrid {
    /// 处理视图出现事件
    ///
    /// 当视图首次出现时，开始加载书籍列表。
    /// 如果播放器有当前音频，会自动选中对应的书籍。
    func handleOnAppear() {
        if Self.verbose {
            os_log("\(self.t)👀 视图已出现")
        }
        
        setIsLoading(true)
        scheduleUpdateBooksDebounced()
        
        // 初始化时检查当前播放的音频
        if let currentAsset = man.asset {
            if Self.verbose {
                os_log("\(self.t)🎵 检测到当前播放: \(currentAsset.lastPathComponent)")
            }
            updateSelectedBook(for: currentAsset)
        }
    }
    
    /// 处理书籍点击事件
    ///
    /// 当用户点击书籍卡片时触发，更新选中状态并开始播放。
    ///
    /// - Parameter book: 被点击的书籍 DTO
    func handleBookTap(book: BookDTO) {
        if Self.verbose {
            os_log("\(self.t)👆 点击书籍: \(book.bookTitle)")
        }
        
        selectedBookURL = book.url
        
        Task {
            await playBook(book)
        }
    }
    
    /// 处理播放资源变化事件
    ///
    /// 当播放器的播放资源改变时触发，更新选中的书籍高亮状态。
    ///
    /// - Parameter url: 新的播放资源 URL，如果为 nil 则清除选中状态
    func handleAssetChanged(_ url: URL?) {
        if Self.verbose {
            if let url = url {
                os_log("\(self.t)🔄 播放资源已变化: \(url.lastPathComponent)")
            } else {
                os_log("\(self.t)🔄 播放已停止")
            }
        }
        
        if let url = url {
            updateSelectedBook(for: url)
        }
    }
    
    /// 处理书籍删除事件
    ///
    /// 当书籍被删除时触发，刷新书籍列表。
    ///
    /// - Parameter notification: 删除完成的通知
    func handleBookDBDeleted(_ notification: Notification) {
        if Self.verbose {
            os_log("\(self.t)🗑️ 书籍已删除")
        }
        scheduleUpdateBooksDebounced()
    }
    
    /// 处理数据同步完成事件
    ///
    /// 当数据库同步完成时触发，刷新书籍列表并结束同步状态。
    ///
    /// - Parameter notification: 同步完成的通知
    func handleBookDBSynced(_ notification: Notification) {
        if Self.verbose {
            os_log("\(self.t)✅ 数据同步完成")
        }
        scheduleUpdateBooksDebounced()
        setIsSyncing(false)
    }
    
    /// 处理排序完成事件
    ///
    /// 当数据库排序完成时触发，刷新书籍列表。
    ///
    /// - Parameter notification: 排序完成的通知
    func handleBookDBSortDone(_ notification: Notification) {
        if Self.verbose {
            os_log("\(self.t)✅ 排序完成")
        }
        scheduleUpdateBooksDebounced()
    }
    
    /// 处理数据更新事件
    ///
    /// 当书籍数据有更新时触发，刷新书籍列表。
    ///
    /// - Parameter notification: 更新完成的通知
    func handleBookDBUpdated(_ notification: Notification) {
        if Self.verbose {
            os_log("\(self.t)🔄 数据已更新")
        }
        scheduleUpdateBooksDebounced()
    }
    
    /// 处理数据同步开始事件
    ///
    /// 当数据库开始同步时触发，显示同步状态。
    ///
    /// - Parameter notification: 同步开始的通知
    func handleBookDBSyncing(_ notification: Notification) {
        if Self.verbose {
            os_log("\(self.t)🔄 开始同步数据")
        }
        setIsSyncing(true)
    }
    
    /// 处理视图消失事件
    ///
    /// 当视图从屏幕上消失时触发，取消待处理的防抖任务。
    func handleOnDisappear() {
        if Self.verbose {
            os_log("\(self.t)👋 视图已消失")
        }
        
        updateBooksDebounceTask?.cancel()
        updateBooksDebounceTask = nil
    }
}

// MARK: - Preview

#if os(macOS)

#endif
