import CisumUIComponents
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

    /// Quick pre-check to see if an index is near the load-more threshold.
    /// Used to avoid calling the full `shouldLoadMore` check for every cell.
    static func isNearThreshold(currentIndex: Int, loadedCount: Int) -> Bool {
        guard loadedCount > 0 else { return false }
        let threshold = max(loadedCount - 15, Int(Double(loadedCount) * 0.75))
        return currentIndex >= threshold
    }

    static func generationAfterDeletingDisplayedItems(_ generation: Int) -> Int {
        generation + 1
    }

    static func currentPageAfterDeletingDisplayedItems(remainingDisplayedCount: Int, pageSize: Int) -> Int {
        guard remainingDisplayedCount > 0, pageSize > 0 else {
            return 0
        }

        return remainingDisplayedCount / pageSize
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
 Display strategy (flat list + paged loading):
 - Only audio files in the repository are shown; folders are not displayed as groups.
 - Files in every subdirectory are flattened and displayed with one unified sort order.
 - Paged loading is used, and the next page is loaded when scrolling reaches 80%.

 Example:
   Root
   ├─ A/
   │  ├─ A1
   │  └─ A2
   └─ B/
      ├─ B1
      └─ B2

   Flattened display: A1, A2, B1, B2 (the A and B directories are hidden)

 Paged loading:
   - Initial load: 50 rows (or calculated dynamically from screen height)
   - Trigger: scroll to the last 10 rows or the 80% position
   - Automatic deduplication: prevents loading the same data twice
 */
struct AudioList: View, SuperThread, SuperLog, SuperEvent {
    nonisolated static let emoji = "📬"
    nonisolated static let verbose = false

    @EnvironmentObject var playManController: MagicPlayMan
    @Environment(\.audioDBDependencies) private var dependencies
    @LumiTheme private var appTheme

    /// Currently selected audio URL.
    @State private var selection: URL? = nil

    /// Audio list URLs that are already loaded.
    @State private var urls: [URL] = []

    /// Whether the first page is loading.
    @State private var isLoading: Bool = false

    /// Whether the next page is loading.
    @State private var isLoadingMore: Bool = false

    /// Whether more data can be loaded.
    @State private var hasMore: Bool = true

    /// Current page number.
    @State private var currentPage: Int = 0

    /// Page size.
    @State private var pageSize: Int = 50

    /// Whether data is syncing.
    @State private var isSyncing: Bool = false

    /// Total audio count for display.
    @State private var totalCount: Int = 0

    /// Current load generation used to discard stale paging tasks started before a refresh.
    @State private var loadGeneration: Int = 0

    /// Current selection generation used to discard stale playback tasks after rapid selection changes.
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

    /// Audio list view.
    private var audioListView: some View {
        List(selection: $selection) {
            Section(header: HStack {
                Text("Total \(totalCount.description)", bundle: .module)
                Spacer()
                if isSyncing {
                    HStack(spacing: 6) {
                        ProgressView()
                            .controlSize(.small)
                        Text("Reading repository", bundle: .module)
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
                // Use the URL as the ID so List selection works correctly.
                ForEach(Array(urls.enumerated()), id: \.element) { index, url in
                    AudioItemView(url)
                        .equatable() // Use Equatable to reduce unnecessary redraws.
                        .listRowBackground(Color.clear)
                        .onAppear {
                            // Only check for more data when approaching the threshold.
                            // This avoids calling checkLoadMore for every cell.
                            if AudioListLoadPolicy.isNearThreshold(
                                currentIndex: index,
                                loadedCount: urls.count
                            ) {
                                checkLoadMore(at: index)
                            }
                        }
                }
                .onDelete(perform: handleDeleteItems)

                // Load-more indicator.
                if isLoadingMore && !urls.isEmpty {
                    HStack {
                        Spacer()
                        ProgressView()
                            .controlSize(.small)
                        Text("Loading more...", bundle: .module)
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
    /// Loads the first page.
    private func loadInitial() {
        guard !isLoading else { return }

        loadGeneration += 1
        let generation = loadGeneration
        isLoading = true

        Task { @MainActor in
            guard let repo = await dependencies.audioRepo() else {
                isLoading = false
                alert_error(String(localized: "Load failed: audio repository is unavailable", bundle: .module))
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
                    os_log("\(self.t)✅ Loaded initial data: \(urls.count) rows, total: \(count)")
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
    }

    /// Checks whether more data should be loaded.
    /// - Parameter index: Index of the currently visible item in the loaded list.
    private func checkLoadMore(at index: Int) {
        // Trigger only near the end when more data exists and no load is in progress.
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

    /// Loads more data.
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

        Task { @MainActor in
            guard let repo = await dependencies.audioRepo() else {
                isLoadingMore = false
                alert_error(String(localized: "Load failed: audio repository is unavailable", bundle: .module))
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
    }

    nonisolated static func nextLoadOffset(loadedCount: Int) -> Int {
        loadedCount
    }

    /// Refreshes the current page while preserving paging state.
    private func refreshCurrentPage(reason: String) {
        // Reload the current page data while preserving paging state.
        loadCurrentPageData(reason: reason)
    }

    /// Fully resets and refreshes.
    private func refresh(reason: String) {
        if Self.verbose {
            os_log("\(self.t)🍋 Refresh with reason: \(reason)")
        }

        AudioItemFileSizeCache.removeAll()

        // Reset state.
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
    /// Sets the selected audio.
    @MainActor
    private func setSelection(_ newValue: URL?, reason: String) {
        if Self.verbose {
            os_log("\(self.t)🔄 (\(reason)) Set selected audio: \(newValue?.lastPathComponent ?? "nil")")
        }
        selection = newValue
    }

    /// Sets the sync state.
    @MainActor
    private func setIsSyncing(_ newValue: Bool) {
        if Self.verbose {
            os_log("\(self.t)🔄 Sync state: \(newValue ? "syncing" : "done")")
        }
        isSyncing = newValue
    }

    /// Loads the current page data to refresh already loaded content.
    private func loadCurrentPageData(reason: String) {
        AudioItemFileSizeCache.removeAll()

        loadGeneration += 1
        let generation = loadGeneration
        let loadingState = AudioListLoadPolicy.loadingStateWhenStartingCurrentPageRefresh(displayedCount: urls.count)
        isLoading = loadingState.isLoading
        isLoadingMore = loadingState.isLoadingMore

        Task { @MainActor in
            guard let repo = await dependencies.audioRepo() else {
                alert_error(String(localized: "Refresh failed: audio repository is unavailable", bundle: .module))
                return
            }

            Task.detached(priority: .background) {
                if Self.verbose {
                    os_log("\(self.t)🔄 Reloading current page data - \(reason)")
                }

            // Get the current state.
            let currentCount = await self.urls.count
            let currentTotalCount = await self.totalCount

            // Fetch the total count again.
            let newTotalCount = await repo.getTotalCount()

            if Self.verbose {
                os_log("\(self.t)📊 Count changed: \(currentTotalCount) → \(newTotalCount), currently loaded: \(currentCount)")
            }

                await MainActor.run {
                guard AudioListLoadPolicy.shouldApplyResult(
                    currentGeneration: self.loadGeneration,
                    resultGeneration: generation
                ) else { return }
                // If the total increased, new files were added and a full reload is needed.
                if newTotalCount > currentTotalCount {
                    if Self.verbose {
                        os_log("\(self.t)✨ New files detected, reloading fully")
                    }
                    self.refresh(reason: "New files - \(reason)")
                    return
                }

                // If the total decreased, files were deleted and a full reload is needed.
                if newTotalCount < currentTotalCount {
                    if Self.verbose {
                        os_log("\(self.t)🗑️ Deleted files detected, reloading fully")
                    }
                    self.refresh(reason: "Deleted files - \(reason)")
                    return
                }

                // When the total is unchanged, refresh only the current page.
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
                                os_log("\(self.t)✅ Current page data refreshed, item count: \(refreshedUrls.count)")
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
}

// MARK: - Event Handler

extension AudioList {
    /// Handles view appearance.
    func handleOnAppear() {
        loadInitial()

        if let asset = playManController.asset {
            if Self.verbose {
                os_log("\(self.t)🎵 Restoring selection to current audio")
            }
            setSelection(asset, reason: "handleOnAppear")
        }
    }

    /// Handles selection changes.
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

                let reason = self.className + ".selectionChanged"
                if Self.verbose {
                    os_log("\(self.t)▶️ (\(reason)) Selection changed, playing: \(url.lastPathComponent)")
                }
                await self.playManController.play(url, reason: reason)
            }
        } else {
            selectionGeneration += 1
        }
    }

    /// Handles playback asset changes.
    func handleAssetChanged(url: URL?) {
        if let asset = url {
            if !AudioListSelectionPolicy.representsSameAudio(asset, selection) {
                self.setSelection(asset, reason: self.className + ".handleAssetChanged")
            }
        } else {
            self.setSelection(nil, reason: self.className + ".handleAssetChanged")
        }
    }

    /// Handles sort completion.
    func handleDBSortDone(_ notification: Notification) {
        if Self.verbose {
            os_log("\(self.t)✅ Sorting finished")
        }
        refresh(reason: "handleDBSortDone")
    }

    /// Handles audio deletion notifications.
    func handleDBDeleted(_ notification: Notification) {
        guard let urlsToDelete = notification.userInfo?["urls"] as? [URL] else {
            if Self.verbose {
                os_log("\(self.t)⚠️ Delete notification did not include URL information")
            }
            return
        }

        if Self.verbose {
            os_log("\(self.t)🗑️ Received delete notification: \(urlsToDelete.count) files")
        }

        // Remove deleted files with animation.
        withAnimation(.easeInOut(duration: 0.3)) {
            loadGeneration = AudioListLoadPolicy.generationAfterDeletingDisplayedItems(loadGeneration)
            isLoading = false
            isLoadingMore = false
            AudioItemFileSizeCache.remove(urlsToDelete)

            // Remove deleted URLs from the displayed list.
            urls.removeAll { url in
                AudioListDeletionPolicy.shouldRemove(url, deletedURLs: urlsToDelete)
            }

            // Update the total count.
            totalCount = AudioListDeletionPolicy.totalCountAfterDeletion(
                currentTotal: totalCount,
                deletedURLs: urlsToDelete
            )
            currentPage = AudioListLoadPolicy.currentPageAfterDeletingDisplayedItems(
                remainingDisplayedCount: urls.count,
                pageSize: pageSize
            )
            hasMore = totalCount > urls.count

            // Clear selection if the selected file was deleted.
            if let selected = selection,
               AudioListDeletionPolicy.shouldRemove(selected, deletedURLs: urlsToDelete) {
                selection = nil
            }
        }

        if Self.verbose {
            os_log("\(self.t)✅ Removed \(urlsToDelete.count) files, remaining: \(urls.count)")
        }
    }

    /// Handles data sync completion.
    func handleDBSynced(_ notification: Notification) {
        refreshCurrentPage(reason: "handleDBSynced")
        setIsSyncing(false)
    }

    /// Handles data updates.
    func handleDBUpdated(_ notification: Notification) {
        refreshCurrentPage(reason: "handleDBUpdated")
        setIsSyncing(false)
    }

    /// Handles data sync start.
    func handleDBSyncing(_ notification: Notification) {
        setIsSyncing(true)
    }

    /// Handles list item deletion.
    ///
    /// Triggered when the user swipes to delete audio from the list, then deletes the files and shows a notification.
    ///
    /// - Parameter offsets: Index set for the items to delete.
    func handleDeleteItems(at offsets: IndexSet) {
        // Get the URLs to delete.
        guard let urlsToDelete = Self.urlsToDelete(from: offsets, in: urls) else {
            alert_error(String(localized: "Delete failed: the audio list changed. Please try again.", bundle: .module))
            return
        }

        if Self.verbose {
            os_log("\(self.t)🗑️ Deleting \(urlsToDelete.count) items")
        }

        Task {
            guard let repo = await dependencies.audioRepo() else {
                alert_error(String(localized: "Delete failed: audio repository is unavailable", bundle: .module))
                return
            }

            do {
                try await repo.deleteAudios(urlsToDelete)
                if AudioDeletePlaybackPolicy.shouldResetDirectlyAfterDelete(
                    currentURL: playManController.currentURL,
                    deletedURLs: urlsToDelete,
                    isPlaybackControllerHandlingDeletion: true
                ) {
                    await playManController.reset(reason: "Delete file")
                }
                for url in urlsToDelete {
                    alert_info(String(localized: "Deleted \(url.title)", bundle: .module))
                }
            } catch {
                alert_error(String(localized: "Delete failed: \(error.localizedDescription)", bundle: .module))
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
