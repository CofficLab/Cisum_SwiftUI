import CisumUI
import MagicAlert
import MagicKit
import OSLog
import SwiftData
import SwiftUI
import PluginAudio
import MagicPlayMan

enum AudioListLoadPolicy {
    static func shouldApplyResult(currentGeneration: Int, resultGeneration: Int) -> Bool {
        currentGeneration == resultGeneration
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
                Text("共 \(totalCount.description)", tableName: "Audio-DBView", bundle: .module)
                Spacer()
                if isSyncing {
                    HStack(spacing: 6) {
                        ProgressView()
                            .controlSize(.small)
                        Text("正在读取仓库", tableName: "Audio-DBView", bundle: .module)
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
                ForEach(urls, id: \.self) { url in
                    AudioItemView(url)
                        .equatable() // 使用 Equatable 优化，减少不必要的重绘
                        .listRowBackground(Color.clear)
                        .onAppear {
                            // 仅在接近列表末尾时检查是否需要加载更多
                            checkLoadMore(for: url)
                        }
                }
                .onDelete(perform: handleDeleteItems)

                // 加载更多指示器
                if isLoadingMore && !urls.isEmpty {
                    HStack {
                        Spacer()
                        ProgressView()
                            .controlSize(.small)
                        Text("正在加载更多...", tableName: "Audio-DBView", bundle: .module)
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
                guard AudioListLoadPolicy.shouldApplyResult(
                    currentGeneration: self.loadGeneration,
                    resultGeneration: generation
                ) else { return }
                self.urls = urls
                self.totalCount = count
                self.currentPage = 1
                self.hasMore = urls.count == self.pageSize
                self.isLoading = false
            }
        }
    }

    /// 检查是否需要加载更多数据
    /// - Parameter url: 当前可见项的 URL
    private func checkLoadMore(for url: URL) {
        // 获取当前 URL 的索引
        guard let currentIndex = urls.firstIndex(of: url) else { return }

        // 计算阈值：最后 10 条或 80% 位置
        let threshold = max(urls.count - 10, Int(Double(urls.count) * 0.8))

        // 仅当接近末尾且有更多数据且未在加载中时触发
        guard currentIndex >= threshold, hasMore, !isLoadingMore else { return }

        if Self.verbose {
            os_log("\(self.t)👁️ Item \(currentIndex) appeared, triggering loadMore")
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
            let existingUrls = await self.urls
            let offset = Self.nextLoadOffset(loadedCount: existingUrls.count)

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

            // 在后台线程进行去重处理（O(n) 而不是 O(n²)）
            let existingUrlsSet = Set(existingUrls)
            let uniqueNewUrls = newUrls.filter { !existingUrlsSet.contains($0) }

            if Self.verbose {
                os_log("\(self.t)🔄 LoadMore - fetched: \(newUrls.count), unique: \(uniqueNewUrls.count)")
            }

            await MainActor.run {
                guard AudioListLoadPolicy.shouldApplyResult(
                    currentGeneration: self.loadGeneration,
                    resultGeneration: generation
                ) else { return }
                if !uniqueNewUrls.isEmpty {
                    self.urls.append(contentsOf: uniqueNewUrls)
                    self.currentPage += 1
                    self.hasMore = uniqueNewUrls.count == self.pageSize
                } else {
                    self.hasMore = false
                }

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

        loadGeneration += 1
        let generation = loadGeneration

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

                            if Self.verbose {
                                os_log("\(self.t)✅ 当前页数据刷新完成，项目数: \(refreshedUrls.count)")
                            }
                        }
                    }
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
            guard url != playManController.currentURL else { return }

            Task {
                let reason = self.className + ".选中项目变了"
                if Self.verbose {
                    os_log("\(self.t)▶️ (\(reason)) 选中变化，播放: \(url.lastPathComponent)")
                }
                await self.playManController.play(url, reason: reason)
            }
        }
    }

    /// 处理播放资源变化事件
    func handleAssetChanged(url: URL?) {
        if let asset = url {
            if asset != selection {
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
            // 从 urls 数组中移除被删除的 URL
            urls.removeAll { url in
                urlsToDelete.contains(url)
            }

            // 更新总数
            totalCount = max(0, totalCount - urlsToDelete.count)

            // 如果删除的是当前选中的文件，清除选中状态
            if let selected = selection, urlsToDelete.contains(selected) {
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
                if AudioDeletePlaybackPolicy.shouldResetAfterDelete(
                    currentURL: playManController.currentURL,
                    deletedURLs: urlsToDelete
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
