import CisumUI
import MagicAlert
import MagicKit
import OSLog
import SwiftData
import SwiftUI
import PluginAudio
import MagicPlayMan

enum AudioListFileIdentity {
    static func canonicalIdentity(for url: URL) -> String {
        guard url.isFileURL else {
            return url.standardized.absoluteString
        }

        if isDanglingSymlink(url) {
            return url.standardizedFileURL.path
        }

        return url.resolvingSymlinksInPath().standardizedFileURL.path
    }

    private static func isDanglingSymlink(_ url: URL) -> Bool {
        guard (try? url.resourceValues(forKeys: [.isSymbolicLinkKey]).isSymbolicLink) == true else {
            return false
        }

        return !FileManager.default.fileExists(atPath: url.path)
    }
}

enum AudioListLoadPolicy {
    static func shouldApplyResult(currentGeneration: Int, resultGeneration: Int) -> Bool {
        currentGeneration == resultGeneration
    }

    static func uniqueAdditionalURLs(existingURLs: [URL], newURLs: [URL]) -> [URL] {
        var seenIdentities = Set(existingURLs.map(canonicalIdentity(for:)))
        var uniqueURLs: [URL] = []
        uniqueURLs.reserveCapacity(newURLs.count)

        for url in newURLs {
            let identity = canonicalIdentity(for: url)
            guard seenIdentities.insert(identity).inserted else { continue }
            uniqueURLs.append(url)
        }

        return uniqueURLs
    }

    static func hasMoreAfterLoading(fetchedCount: Int, pageSize: Int) -> Bool {
        fetchedCount == pageSize
    }

    static func shouldKeepLoadingStateWhenDiscardingStaleResult(
        currentGeneration: Int,
        resultGeneration: Int
    ) -> Bool {
        currentGeneration != resultGeneration
    }

    static func loadingStateWhenStartingCurrentPageRefresh(displayedCount: Int) -> (isLoading: Bool, isLoadingMore: Bool) {
        (isLoading: displayedCount == 0, isLoadingMore: false)
    }

    static func shouldLoadMore(
        currentIndex: Int,
        loadedCount: Int,
        hasMore: Bool,
        isLoadingMore: Bool
    ) -> Bool {
        guard loadedCount > 0, currentIndex >= 0, hasMore, !isLoadingMore else {
            return false
        }

        let threshold = max(loadedCount - 10, Int(Double(loadedCount) * 0.8))
        return currentIndex >= threshold
    }

    static func generationAfterDeletingDisplayedItems(_ generation: Int) -> Int {
        generation + 1
    }

    static func nextLoadOffset(loadedCount: Int, currentPage: Int, pageSize: Int) -> Int {
        max(0, max(loadedCount, currentPage * pageSize))
    }

    static func pageAfterLoading(currentPage: Int, fetchedCount: Int) -> Int {
        fetchedCount > 0 ? currentPage + 1 : currentPage
    }

    private static func canonicalIdentity(for url: URL) -> String {
        AudioListFileIdentity.canonicalIdentity(for: url)
    }
}

enum AudioListDeletionPolicy {
    static func shouldRemove(_ url: URL, deletedURLs: [URL]) -> Bool {
        AudioDeletePlaybackPolicy.deletedURLsContainCurrentAudio(
            currentURL: url,
            deletedURLs: deletedURLs
        )
    }

    static func removedDisplayedCount(from displayedURLs: [URL], deletedURLs: [URL]) -> Int {
        displayedURLs.filter { shouldRemove($0, deletedURLs: deletedURLs) }.count
    }

    static func totalCountAfterDeletion(currentTotal: Int, deletedURLs: [URL]) -> Int {
        max(0, currentTotal - uniqueDeletedCount(deletedURLs))
    }

    private static func uniqueDeletedCount(_ deletedURLs: [URL]) -> Int {
        Set(deletedURLs.map(canonicalIdentity(for:))).count
    }

    private static func canonicalIdentity(for url: URL) -> String {
        AudioListFileIdentity.canonicalIdentity(for: url)
    }
}

enum AudioListSelectionPolicy {
    static func shouldApplySelection(
        currentGeneration: Int,
        requestGeneration: Int,
        requestedURL: URL,
        selection: URL?,
        displayedURLs: [URL]
    ) -> Bool {
        currentGeneration == requestGeneration
            && representsSameAudio(requestedURL, selection)
            && displayedURLs.contains { representsSameAudio($0, requestedURL) }
    }

    static func representsSameAudio(_ lhs: URL?, _ rhs: URL?) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none):
            return true
        case let (.some(lhs), .some(rhs)):
            return resolvedStandardizedPath(for: lhs) == resolvedStandardizedPath(for: rhs)
        default:
            return false
        }
    }

    private static func resolvedStandardizedPath(for url: URL) -> String {
        AudioListFileIdentity.canonicalIdentity(for: url)
    }
}

/*
 展示策略（扁平化列表 + 分页加载）：
 - 仅展示仓库中的音频文件；文件夹不会作为分组出现
 - 所有子目录中的文件被"拍平"后按统一规则排序与展示
 - 采用分页加载策略，滚动到 80% 位置时自动加载下一页

 示例：
   根目录
   ├─ A/
   │  ├─ A1
   │  └─ A2
   └─ B/
      ├─ B1
      └─ B2

   扁平化后展示为：A1、A2、B1、B2（不显示 A、B 目录本身）

 分页加载：
   - 初始加载：50 条（或根据屏幕高度动态计算）
   - 触发加载：滚动到倒数 10 条或 80% 位置
   - 自动去重：防止重复加载相同数据
 */
struct AudioList: View, SuperThread, SuperLog, SuperEvent {
    nonisolated static let emoji = "📬"
    nonisolated static let verbose = false

    @EnvironmentObject var playManController: MagicPlayMan
    @Environment(\.audioDBDependencies) private var dependencies
    @LumiTheme private var appTheme

    /// 当前选中的音频 URL
    @State private var selection: URL? = nil

    /// 音频列表 URL 数组（已加载的数据）
    @State private var urls: [URL] = []

    /// 是否正在加载
    @State private var isLoading: Bool = false

    /// 是否正在加载更多
    @State private var isLoadingMore: Bool = false

    /// 是否还有更多数据可加载
    @State private var hasMore: Bool = true

    /// 当前页码
    @State private var currentPage: Int = 0

    /// 每页大小
    @State private var pageSize: Int = 50

    /// 是否正在同步数据
    @State private var isSyncing: Bool = false

    /// 音频总数（显示用）
    @State private var totalCount: Int = 0

    /// 当前加载世代，用于丢弃刷新前启动的过期分页任务。
    @State private var loadGeneration: Int = 0

    /// 当前选择播放世代，用于丢弃快速点选时过期的播放任务。
    @State private var selectionGeneration: Int = 0

    var body: some View {
        ZStack {
            audioListView

            if isLoading && urls.isEmpty {
                AudioDBTips(variant: .loading)
            } else if urls.isEmpty && !isLoading {
                AudioDBTips(variant: .empty)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(appTheme.background.ignoresSafeArea())
        .onAppear(perform: handleOnAppear)
        .onChange(of: selection, handleSelectionChange)
        .onDBDeleted(perform: handleDBDeleted)
        .onDBSynced(perform: handleDBSynced)
        .onDBSortDone(perform: handleDBSortDone)
        .onDBUpdated(perform: handleDBUpdated)
        .onDBSyncing(perform: handleDBSyncing)
        .onPlayManAssetChanged(handleAssetChanged)
    }

    /// 音频列表视图
    private var audioListView: some View {
        List(selection: $selection) {
            Section(header: HStack {
                Text("Total \(totalCount.description)", tableName: "Audio-DBView", bundle: .module)
                Spacer()
                if isSyncing {
                    HStack(spacing: 6) {
                        ProgressView()
                            .controlSize(.small)
                        Text("Reading repository", tableName: "Audio-DBView", bundle: .module)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }

                if dependencies.isNotDesktop {
                    BtnAdd()
                        .font(.title2)
                        .labelStyle(.iconOnly)
                }
            }, content: {
                // 使用 URL 作为 id，确保 List selection 能正确工作
                ForEach(Array(urls.enumerated()), id: \.element) { index, url in
                    AudioItemView(url)
                        .equatable() // 使用 Equatable 优化，减少不必要的重绘
                        .listRowBackground(Color.clear)
                        .onAppear {
                            // 仅在接近列表末尾时检查是否需要加载更多
                            checkLoadMore(at: index)
                        }
                }
                .onDelete(perform: handleDeleteItems)

                // 加载更多指示器
                if isLoadingMore && !urls.isEmpty {
                    HStack {
                        Spacer()
                        ProgressView()
                            .controlSize(.small)
                        Text("Loading more...", tableName: "Audio-DBView", bundle: .module)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    .frame(height: 44)
                    .listRowBackground(Color.clear)
                }
            })
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(appTheme.background.ignoresSafeArea())
    }
}

// MARK: - Action

extension AudioList {
    /// 加载第一页数据
    private func loadInitial() {
        guard !isLoading else { return }

        loadGeneration += 1
        let generation = loadGeneration
        isLoading = true

        guard let repo = dependencies.audioRepo() else {
            isLoading = false
            alert_error(String(localized: "Load failed: audio repository is unavailable", table: "Audio-DBView", bundle: .module))
            return
        }

        Task.detached(priority: .background) {
            let count = await repo.getTotalCount()
            let urls = await repo.get(
                offset: 0,
                limit: self.pageSize,
                reason: self.className
            )

            if Self.verbose {
                os_log("\(self.t)✅ 加载初始数据: \(urls.count) 条，总数: \(count)")
            }

            await MainActor.run {
                guard !AudioListLoadPolicy.shouldKeepLoadingStateWhenDiscardingStaleResult(
                    currentGeneration: self.loadGeneration,
                    resultGeneration: generation
                ) else {
                    return
                }
                self.urls = urls
                self.totalCount = count
                self.currentPage = 1
                self.hasMore = urls.count == self.pageSize
                self.isLoading = false
            }
        }
    }

    /// 检查是否需要加载更多数据
    /// - Parameter index: 当前可见项在已加载列表中的索引
    private func checkLoadMore(at index: Int) {
        // 仅当接近末尾且有更多数据且未在加载中时触发
        guard AudioListLoadPolicy.shouldLoadMore(
            currentIndex: index,
            loadedCount: urls.count,
            hasMore: hasMore,
            isLoadingMore: isLoadingMore
        ) else { return }

        if Self.verbose {
            os_log("\(self.t)👁️ Item \(index) appeared, triggering loadMore")
        }
        loadMore()
    }

    /// 加载更多数据
    private func loadMore() {
        guard !isLoadingMore, hasMore else {
            if Self.verbose {
                os_log("\(self.t)🔄 LoadMore skipped - isLoadingMore: \(isLoadingMore), hasMore: \(hasMore)")
            }
            return
        }

        if Self.verbose {
            os_log("\(self.t)🔄 LoadMore started - page: \(currentPage), current: \(urls.count)")
        }

        isLoadingMore = true
        let generation = loadGeneration

        guard let repo = dependencies.audioRepo() else {
            isLoadingMore = false
            alert_error(String(localized: "Load failed: audio repository is unavailable", table: "Audio-DBView", bundle: .module))
            return
        }

        Task.detached(priority: .background) {
            let pageSize = await self.pageSize
            let currentPage = await self.currentPage
            let existingUrls = await self.urls
            let offset = AudioListLoadPolicy.nextLoadOffset(
                loadedCount: existingUrls.count,
                currentPage: currentPage,
                pageSize: pageSize
            )

            if Self.verbose {
                os_log("\(self.t)🔄 LoadMore - offset: \(offset), limit: \(pageSize)")
            }

            let newUrls = await repo.get(
                offset: offset,
                limit: pageSize,
                reason: self.className
            )

            if Self.verbose {
                os_log("\(self.t)🔄 LoadMore - fetched: \(newUrls.count) urls")
            }

            let uniqueNewUrls = AudioListLoadPolicy.uniqueAdditionalURLs(
                existingURLs: existingUrls,
                newURLs: newUrls
            )

            if Self.verbose {
                os_log("\(self.t)🔄 LoadMore - fetched: \(newUrls.count), unique: \(uniqueNewUrls.count)")
            }

            await MainActor.run {
                guard !AudioListLoadPolicy.shouldKeepLoadingStateWhenDiscardingStaleResult(
                    currentGeneration: self.loadGeneration,
                    resultGeneration: generation
                ) else {
                    return
                }
                if !uniqueNewUrls.isEmpty {
                    self.urls.append(contentsOf: uniqueNewUrls)
                    self.hasMore = AudioListLoadPolicy.hasMoreAfterLoading(
                        fetchedCount: newUrls.count,
                        pageSize: self.pageSize
                    )
                } else {
                    self.hasMore = AudioListLoadPolicy.hasMoreAfterLoading(
                        fetchedCount: newUrls.count,
                        pageSize: self.pageSize
                    )
                }
                self.currentPage = AudioListLoadPolicy.pageAfterLoading(
                    currentPage: self.currentPage,
                    fetchedCount: newUrls.count
                )

                self.isLoadingMore = false
            }
        }
    }

    nonisolated static func nextLoadOffset(loadedCount: Int) -> Int {
        loadedCount
    }

    /// 刷新当前页数据（保持分页状态）
    private func refreshCurrentPage(reason: String) {
        // 重新加载当前页的数据，但保持分页状态
        loadCurrentPageData(reason: reason)
    }

    /// 完全重置并刷新
    private func refresh(reason: String) {
        if Self.verbose {
            os_log("\(self.t)🍋 Refresh with reason: \(reason)")
        }

        AudioItemFileSizeCache.removeAll()

        // 重置状态
        loadGeneration += 1
        currentPage = 0
        hasMore = true
        urls = []
        isLoading = false
        isLoadingMore = false

        loadInitial()
    }
}

// MARK: - Setter

extension AudioList {
    /// 设置选中的音频
    @MainActor
    private func setSelection(_ newValue: URL?, reason: String) {
        if Self.verbose {
            os_log("\(self.t)🔄 (\(reason)) 设置选中音频: \(newValue?.lastPathComponent ?? "nil")")
        }
        selection = newValue
    }

    /// 设置同步状态
    @MainActor
    private func setIsSyncing(_ newValue: Bool) {
        if Self.verbose {
            os_log("\(self.t)🔄 同步状态: \(newValue ? "同步中" : "完成")")
        }
        isSyncing = newValue
    }

    /// 加载当前页数据（用于刷新当前已加载的内容）
    private func loadCurrentPageData(reason: String) {
        guard let repo = dependencies.audioRepo() else {
            alert_error(String(localized: "Refresh failed: audio repository is unavailable", table: "Audio-DBView", bundle: .module))
            return
        }

        AudioItemFileSizeCache.removeAll()

        loadGeneration += 1
        let generation = loadGeneration
        let loadingState = AudioListLoadPolicy.loadingStateWhenStartingCurrentPageRefresh(displayedCount: urls.count)
        isLoading = loadingState.isLoading
        isLoadingMore = loadingState.isLoadingMore

        Task.detached(priority: .background) {
            if Self.verbose {
                os_log("\(self.t)🔄 重新加载当前页数据 - \(reason)")
            }

            // 获取当前状态
            let currentCount = await self.urls.count
            let currentTotalCount = await self.totalCount

            // 重新获取总数
            let newTotalCount = await repo.getTotalCount()

            if Self.verbose {
                os_log("\(self.t)📊 计数变化：\(currentTotalCount) → \(newTotalCount)，当前已加载：\(currentCount)")
            }

            await MainActor.run {
                guard AudioListLoadPolicy.shouldApplyResult(
                    currentGeneration: self.loadGeneration,
                    resultGeneration: generation
                ) else { return }
                // 如果总数增加（新增文件），需要完全重新加载
                if newTotalCount > currentTotalCount {
                    if Self.verbose {
                        os_log("\(self.t)✨ 检测到新增文件，完全重新加载")
                    }
                    self.refresh(reason: "新增文件 - \(reason)")
                    return
                }

                // 如果总数减少（删除文件），也需要完全重新加载
                if newTotalCount < currentTotalCount {
                    if Self.verbose {
                        os_log("\(self.t)🗑️ 检测到删除文件，完全重新加载")
                    }
                    self.refresh(reason: "删除文件 - \(reason)")
                    return
                }

                // 总数不变，只刷新当前页数据
                if currentCount > 0 {
                    Task.detached(priority: .background) {
                        let refreshedUrls = await repo.get(
                            offset: 0,
                            limit: currentCount,
                            reason: self.className
                        )

                        await MainActor.run {
                            guard AudioListLoadPolicy.shouldApplyResult(
                                currentGeneration: self.loadGeneration,
                                resultGeneration: generation
                            ) else { return }
                            self.urls = refreshedUrls
                            self.totalCount = newTotalCount
                            self.isLoading = false
                            self.isLoadingMore = false

                            if Self.verbose {
                                os_log("\(self.t)✅ 当前页数据刷新完成，项目数: \(refreshedUrls.count)")
                            }
                        }
                    }
                } else {
                    self.totalCount = newTotalCount
                    self.isLoading = false
                    self.isLoadingMore = false
                }
            }
        }
    }
}

// MARK: - Event Handler

extension AudioList {
    /// 处理视图出现事件
    func handleOnAppear() {
        loadInitial()

        if let asset = playManController.asset {
            if Self.verbose {
                os_log("\(self.t)🎵 恢复选中当前播放的音频")
            }
            setSelection(asset, reason: "handleOnAppear")
        }
    }

    /// 处理选中项变化事件
    func handleSelectionChange() {
        if let url = selection, isLoading == false {
            guard !AudioListSelectionPolicy.representsSameAudio(url, playManController.currentURL) else { return }

            selectionGeneration += 1
            let generation = selectionGeneration

            Task { @MainActor in
                guard AudioListSelectionPolicy.shouldApplySelection(
                    currentGeneration: selectionGeneration,
                    requestGeneration: generation,
                    requestedURL: url,
                    selection: selection,
                    displayedURLs: urls
                ) else {
                    return
                }

                let reason = self.className + ".选中项目变了"
                if Self.verbose {
                    os_log("\(self.t)▶️ (\(reason)) 选中变化，播放: \(url.lastPathComponent)")
                }
                await self.playManController.play(url, reason: reason)
            }
        } else {
            selectionGeneration += 1
        }
    }

    /// 处理播放资源变化事件
    func handleAssetChanged(url: URL?) {
        if let asset = url {
            if !AudioListSelectionPolicy.representsSameAudio(asset, selection) {
                self.setSelection(asset, reason: self.className + ".handleAssetChanged")
            }
        } else {
            self.setSelection(nil, reason: self.className + ".handleAssetChanged")
        }
    }

    /// 处理排序完成事件
    func handleDBSortDone(_ notification: Notification) {
        if Self.verbose {
            os_log("\(self.t)✅ 排序完成")
        }
        refresh(reason: "handleDBSortDone")
    }

    /// 处理音频删除事件
    func handleDBDeleted(_ notification: Notification) {
        guard let urlsToDelete = notification.userInfo?["urls"] as? [URL] else {
            if Self.verbose {
                os_log("\(self.t)⚠️ 删除通知中没有 URL 信息")
            }
            return
        }

        if Self.verbose {
            os_log("\(self.t)🗑️ 收到删除通知: \(urlsToDelete.count) 个文件")
        }

        // 使用动画效果移除已删除的文件
        withAnimation(.easeInOut(duration: 0.3)) {
            loadGeneration = AudioListLoadPolicy.generationAfterDeletingDisplayedItems(loadGeneration)
            isLoading = false
            isLoadingMore = false
            AudioItemFileSizeCache.remove(urlsToDelete)

            // 从 urls 数组中移除被删除的 URL
            urls.removeAll { url in
                AudioListDeletionPolicy.shouldRemove(url, deletedURLs: urlsToDelete)
            }

            // 更新总数
            totalCount = AudioListDeletionPolicy.totalCountAfterDeletion(
                currentTotal: totalCount,
                deletedURLs: urlsToDelete
            )

            // 如果删除的是当前选中的文件，清除选中状态
            if let selected = selection,
               AudioListDeletionPolicy.shouldRemove(selected, deletedURLs: urlsToDelete) {
                selection = nil
            }
        }

        if Self.verbose {
            os_log("\(self.t)✅ 已移除 \(urlsToDelete.count) 个文件，剩余 \(urls.count) 个")
        }
    }

    /// 处理数据同步完成事件
    func handleDBSynced(_ notification: Notification) {
        refreshCurrentPage(reason: "handleDBSynced")
        setIsSyncing(false)
    }

    /// 处理数据更新事件
    func handleDBUpdated(_ notification: Notification) {
        refreshCurrentPage(reason: "handleDBUpdated")
        setIsSyncing(false)
    }

    /// 处理数据同步开始事件
    func handleDBSyncing(_ notification: Notification) {
        setIsSyncing(true)
    }

    /// 处理删除列表项事件
    ///
    /// 当用户通过列表滑动删除音频时触发，删除文件并显示提示。
    ///
    /// - Parameter offsets: 要删除的项目索引集合
    func handleDeleteItems(at offsets: IndexSet) {
        // 获取要删除的 URLs
        guard let urlsToDelete = Self.urlsToDelete(from: offsets, in: urls) else {
            alert_error(String(localized: "Delete failed: the audio list changed. Please try again.", table: "Audio-DBView", bundle: .module))
            return
        }

        if Self.verbose {
            os_log("\(self.t)🗑️ 删除 \(urlsToDelete.count) 个项目")
        }

        Task {
            guard let repo = dependencies.audioRepo() else {
                alert_error(String(localized: "Delete failed: audio repository is unavailable", table: "Audio-DBView", bundle: .module))
                return
            }

            do {
                try await repo.deleteAudios(urlsToDelete)
                if AudioDeletePlaybackPolicy.shouldResetDirectlyAfterDelete(
                    currentURL: playManController.currentURL,
                    deletedURLs: urlsToDelete,
                    isPlaybackControllerHandlingDeletion: true
                ) {
                    await playManController.reset(reason: "删除文件")
                }
                for url in urlsToDelete {
                    alert_info(String(localized: "Deleted \(url.title)", table: "Audio-DBView", bundle: .module))
                }
            } catch {
                alert_error(String(localized: "Delete failed: \(error.localizedDescription)", table: "Audio-DBView", bundle: .module))
            }
        }
    }

    nonisolated static func urlsToDelete(from offsets: IndexSet, in urls: [URL]) -> [URL]? {
        var urlsToDelete: [URL] = []
        urlsToDelete.reserveCapacity(offsets.count)

        for offset in offsets {
            guard urls.indices.contains(offset) else {
                return nil
            }
            urlsToDelete.append(urls[offset])
        }

        return urlsToDelete
    }
}
