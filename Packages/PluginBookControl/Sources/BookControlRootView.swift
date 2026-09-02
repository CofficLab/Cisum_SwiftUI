import Foundation
import CisumUIComponents
import MagicPlayMan
import OSLog
import PluginBook
import SwiftUI

public typealias BookControlCurrentSceneProvider = @MainActor () -> String?

enum BookControlBookRootResolver {
    static func bookRoot(containing url: URL, bookDisk: URL?) -> URL {
        let parent = url.deletingLastPathComponent().standardizedFileURL

        guard let bookDisk else {
            return parent
        }

        let disk = bookDisk.standardizedFileURL
        let url = url.standardizedFileURL

        guard BookControlPathContainment.resolved(url, isContainedIn: disk) else {
            return parent
        }

        guard isContained(url.path, in: disk.path) else {
            return mappedBookRoot(for: url, in: disk)
        }

        guard parent.path != disk.path else {
            return url
        }

        var candidate = parent
        while candidate.deletingLastPathComponent().standardizedFileURL.path != disk.path,
              isContained(candidate.path, in: disk.path) {
            candidate = candidate.deletingLastPathComponent().standardizedFileURL
        }

        return candidate
    }

    private static func mappedBookRoot(for url: URL, in disk: URL) -> URL {
        let resolvedURLPath = BookControlPathContainment.resolvedStandardizedPath(for: url)
        let resolvedDiskPath = BookControlPathContainment.resolvedStandardizedPath(for: disk)

        guard let relativePath = BookControlPathContainment.relativePath(of: resolvedURLPath, in: resolvedDiskPath),
              !relativePath.isEmpty else {
            return disk
        }

        guard let topLevelComponent = relativePath.split(separator: "/", omittingEmptySubsequences: true).first else {
            return disk
        }

        let isDirectory = relativePath.contains("/")
        return disk.appendingPathComponent(String(topLevelComponent), isDirectory: isDirectory).standardizedFileURL
    }

    private static func isContained(_ childPath: String, in parentPath: String) -> Bool {
        childPath == parentPath || childPath.hasPrefix(parentPath.hasSuffix("/") ? parentPath : parentPath + "/")
    }
}

enum BookControlPathContainment {
    static func resolved(_ child: URL, isContainedIn parent: URL) -> Bool {
        isContained(resolvedStandardizedPath(for: child), in: resolvedStandardizedPath(for: parent))
    }

    static func resolvedStandardizedPath(for url: URL) -> String {
        url.resolvingSymlinksInPath().standardizedFileURL.path
    }

    static func relativePath(of childPath: String, in parentPath: String) -> String? {
        if childPath == parentPath {
            return ""
        }

        let prefix = parentPath.hasSuffix("/") ? parentPath : parentPath + "/"
        guard childPath.hasPrefix(prefix) else {
            return nil
        }

        return String(childPath.dropFirst(prefix.count))
    }

    private static func isContained(_ childPath: String, in parentPath: String) -> Bool {
        childPath == parentPath || childPath.hasPrefix(parentPath.hasSuffix("/") ? parentPath : parentPath + "/")
    }
}

enum BookControlFileLocationIdentity {
    static func representsSameFile(_ lhs: URL?, _ rhs: URL?) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none):
            return true
        case let (.some(lhs), .some(rhs)):
            return stablePath(for: lhs) == stablePath(for: rhs)
        default:
            return false
        }
    }

    static func containmentPaths(for url: URL) -> Set<String> {
        if FileManager.default.fileExists(atPath: url.path) {
            return [
                url.standardizedFileURL.path,
                url.resolvingSymlinksInPath().standardizedFileURL.path,
            ]
        }

        return [url.standardizedFileURL.path]
    }

    private static func stablePath(for url: URL) -> String {
        if FileManager.default.fileExists(atPath: url.path) {
            return url.resolvingSymlinksInPath().standardizedFileURL.path
        }

        return url.standardizedFileURL.path
    }
}

enum BookControlPlaybackRequestPolicy {
    static func shouldNavigateBookAsset(_ asset: URL, bookDisk: URL?) -> Bool {
        guard let bookDisk else { return true }
        return BookControlPathContainment.resolved(asset, isContainedIn: bookDisk)
    }

    static func shouldApplyNavigationResult(
        requestedAsset: URL,
        currentAsset: URL?,
        isSceneActive: Bool,
        currentGeneration: Int = 0,
        requestGeneration: Int = 0
    ) -> Bool {
        currentGeneration == requestGeneration
            && isSceneActive
            && representsSameFile(requestedAsset, currentAsset)
    }

    static func currentAssetAffectedByDeletion(currentAsset: URL?, deletedURLs: [URL]) -> Bool {
        guard let currentAsset else { return false }
        let assetPaths = BookControlFileLocationIdentity.containmentPaths(for: currentAsset)
        return deletedURLs.contains { deletedURL in
            BookControlFileLocationIdentity.containmentPaths(for: deletedURL).contains { parentPath in
                assetPaths.contains { assetPath in
                    isContained(assetPath, in: parentPath)
                }
            }
        }
    }

    static func shouldApplyDeletionReset(
        currentAsset: URL?,
        deletedURLs: [URL],
        currentGeneration: Int,
        requestGeneration: Int
    ) -> Bool {
        currentGeneration == requestGeneration
            && currentAssetAffectedByDeletion(currentAsset: currentAsset, deletedURLs: deletedURLs)
    }

    static func shouldInvalidateChapterCacheAfterDeletion(deletedURLs: [URL]) -> Bool {
        !deletedURLs.isEmpty
    }

    static func shouldInvalidateChapterCacheAfterLibraryRefresh() -> Bool {
        true
    }

    static func shouldResetForStorageLocationChange(isSceneActive: Bool) -> Bool {
        isSceneActive
    }

    static func shouldApplyStorageReset(
        currentGeneration: Int,
        requestGeneration: Int,
        isSceneActive: Bool
    ) -> Bool {
        currentGeneration == requestGeneration && isSceneActive
    }

    static func generationAfterDeactivation(_ generation: Int) -> Int {
        generation + 1
    }

    private static func representsSameFile(_ lhs: URL?, _ rhs: URL?) -> Bool {
        BookControlFileLocationIdentity.representsSameFile(lhs, rhs)
    }

    private static func isContained(_ childPath: String, in parentPath: String) -> Bool {
        childPath == parentPath || childPath.hasPrefix(parentPath.hasSuffix("/") ? parentPath : parentPath + "/")
    }
}

enum BookControlChapterLoader {
    static func relativePath(_ url: URL, in root: URL) -> String {
        let rootPath = root.standardizedFileURL.path
        let path = url.standardizedFileURL.path

        guard isContained(path, in: rootPath) else {
            return url.lastPathComponent
        }

        return String(path.dropFirst(rootPath.count)).trimmingCharacters(in: CharacterSet(charactersIn: "/"))
    }

    private static func isContained(_ path: String, in rootPath: String) -> Bool {
        path == rootPath || path.hasPrefix(rootPath.hasSuffix("/") ? rootPath : rootPath + "/")
    }

    static func playableChapters(in root: URL) -> [URL] {
        let scanRoot = root.isFolder ? root : root.resolvingSymlinksInPath().standardizedFileURL

        return playableFiles(in: scanRoot)
            .map { mappedURL($0, from: scanRoot, to: root) }
            .sorted {
                relativePath($0, in: root).localizedStandardCompare(relativePath($1, in: root)) == .orderedAscending
            }
    }

    private static func playableFiles(in root: URL) -> [URL] {
        guard root.isFolder else {
            return isPlayableFile(root) ? [root] : []
        }

        guard let enumerator = FileManager.default.enumerator(
            at: root,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }

        var files: [URL] = []
        for case let url as URL in enumerator {
            guard !url.isFolder, isPlayableFile(url) else { continue }
            files.append(url)
        }

        return files
    }

    private static func isPlayableFile(_ url: URL) -> Bool {
        FileManager.default.fileExists(atPath: url.path)
            && BookPluginInfo.supportedExtensions.contains(url.pathExtension.lowercased())
    }

    private static func mappedURL(_ url: URL, from scanRoot: URL, to root: URL) -> URL {
        let scanRootPath = scanRoot.standardizedFileURL.path
        let rootPath = root.standardizedFileURL.path
        let urlPath = url.standardizedFileURL.path

        guard scanRootPath != rootPath,
              let relativePath = BookControlPathContainment.relativePath(of: urlPath, in: scanRootPath) else {
            return url
        }

        return root.appendingPathComponent(relativePath).standardizedFileURL
    }

    static func adjacentAsset(
        in chapters: [URL],
        current asset: URL,
        offset: Int,
        playMode: MagicPlayMode
    ) -> URL? {
        guard !chapters.isEmpty,
              let index = chapters.firstIndex(where: { isSameFile($0, asset) }) else { return nil }

        let adjacentIndex = index + offset
        if chapters.indices.contains(adjacentIndex) {
            return chapters[adjacentIndex]
        }

        switch playMode {
        case .repeatAll:
            return offset > 0 ? chapters.first : chapters.last
        case .shuffle:
            return shuffleCandidates(in: chapters, current: asset).randomElement() ?? chapters.first
        case .sequence, .loop:
            return nil
        }
    }

    static func shuffleCandidates(in chapters: [URL], current asset: URL) -> [URL] {
        chapters.filter { !isSameFile($0, asset) }
    }

    private static func isSameFile(_ lhs: URL, _ rhs: URL) -> Bool {
        BookControlFileLocationIdentity.representsSameFile(lhs, rhs)
    }
}

@MainActor
enum BookControlChapterCache {
    private static var chaptersByRoot: [String: [URL]] = [:]

    static func cachedChapters(in root: URL) -> [URL]? {
        chaptersByRoot[cacheKey(for: root)]
    }

    static func store(_ chapters: [URL], in root: URL) {
        chaptersByRoot[cacheKey(for: root)] = chapters
    }

    static func removeAll() {
        chaptersByRoot.removeAll()
    }

    private static func cacheKey(for root: URL) -> String {
        if FileManager.default.fileExists(atPath: root.path) {
            return root.resolvingSymlinksInPath().standardizedFileURL.path
        }

        return root.standardizedFileURL.path
    }
}

public struct BookControlRootView<Content>: View, SuperLog where Content: View {
    public nonisolated static var emoji: String { BookControlPluginInfo.emoji }
    private let verbose = false

    @EnvironmentObject private var man: MagicPlayMan
    @State private var playbackSubscriptionID: UUID?
    @State private var controlGeneration = 0

    private let content: Content
    private let targetSceneName: String
    private let currentSceneName: BookControlCurrentSceneProvider

    public init(
        targetSceneName: String,
        currentSceneName: @escaping BookControlCurrentSceneProvider,
        @ViewBuilder content: () -> Content
    ) {
        self.targetSceneName = targetSceneName
        self.currentSceneName = currentSceneName
        self.content = content()
    }

    public var body: some View {
        content
            .onAppear(perform: handleOnAppear)
            .onDisappear(perform: handleOnDisappear)
            .onChange(of: currentSceneName()) { _, newSceneName in
                handleCurrentSceneChanged(newSceneName)
            }
            .onReceive(NotificationCenter.default.publisher(for: .bookDBDeleted), perform: handleBookDBDeleted)
            .onReceive(NotificationCenter.default.publisher(for: .bookDBSynced), perform: handleBookDBRefreshed)
            .onReceive(NotificationCenter.default.publisher(for: .bookDBUpdated), perform: handleBookDBRefreshed)
            .onReceive(NotificationCenter.default.publisher(for: .bookControlStorageLocationDidReset)) { _ in
                handleStorageLocationDidReset()
            }
    }

    /// 检查是否应该激活书籍播放控制功能
    private var shouldActivateControl: Bool {
        currentSceneName() == targetSceneName
    }
}

// MARK: - Action

extension BookControlRootView {
    /// 处理视图出现事件
    ///
    /// 当视图首次出现时触发，执行初始化操作。
    func handleOnAppear() {
        updateControlActivation(for: currentSceneName())
    }

    func handleCurrentSceneChanged(_ sceneName: String?) {
        updateControlActivation(for: sceneName)
    }

    private func updateControlActivation(for sceneName: String?) {
        if sceneName == targetSceneName {
            activateControl()
        } else {
            deactivateControl()
        }
    }

    private func activateControl() {
        guard shouldActivateControl else {
            if verbose {
                os_log("\(self.t)⏭️ Skipping audiobook playback controls: current scene is not Books")
            }
            return
        }

        if verbose {
            os_log("\(self.t)👀 View appeared, initializing audiobook playback controls")
        }

        // 订阅播放器事件
        guard playbackSubscriptionID == nil else { return }

        playbackSubscriptionID = man.subscribe(
            name: "BookControlPlugin",
            onPreviousRequested: { asset in
                handlePreviousRequested(asset)
            },
            onNextRequested: { asset in
                handleNextRequested(asset)
            }
        )
    }

    func handleOnDisappear() {
        deactivateControl()
    }

    private func deactivateControl() {
        controlGeneration = BookControlPlaybackRequestPolicy.generationAfterDeactivation(controlGeneration)
        BookControlChapterCache.removeAll()

        guard let playbackSubscriptionID else { return }

        man.unsubscribe(playbackSubscriptionID)
        self.playbackSubscriptionID = nil
    }

    func bookRoot(containing asset: URL) -> URL {
        BookControlBookRootResolver.bookRoot(containing: asset, bookDisk: BookPlugin.getBookDisk())
    }

    func relativePath(_ url: URL, in root: URL) -> String {
        BookControlChapterLoader.relativePath(url, in: root)
    }

    func playableChapters(of asset: URL) -> [URL] {
        let bookDisk = BookPlugin.getBookDisk()
        guard BookControlPlaybackRequestPolicy.shouldNavigateBookAsset(asset, bookDisk: bookDisk) else {
            return []
        }

        let root = BookControlBookRootResolver.bookRoot(containing: asset, bookDisk: bookDisk)
        return BookControlChapterLoader.playableChapters(in: root)
    }

    func adjacentAsset(to asset: URL, offset: Int) -> URL? {
        let chapters = playableChapters(of: asset)
        return Self.adjacentAsset(
            in: chapters,
            current: asset,
            offset: offset,
            playMode: man.playMode
        )
    }

    func contains(_ parent: URL, asset: URL) -> Bool {
        let parentPath = parent.standardizedFileURL.path
        let assetPath = asset.standardizedFileURL.path
        return assetPath == parentPath || assetPath.hasPrefix(parentPath + "/")
    }

    func handleBookDBDeleted(_ notification: Notification) {
        guard let deletedURLs = notification.userInfo?["urls"] as? [URL] else {
            return
        }

        if BookControlPlaybackRequestPolicy.shouldInvalidateChapterCacheAfterDeletion(deletedURLs: deletedURLs) {
            BookControlChapterCache.removeAll()
        }

        guard BookControlPlaybackRequestPolicy.currentAssetAffectedByDeletion(
            currentAsset: man.asset,
            deletedURLs: deletedURLs
        ) else {
            return
        }

        let generation = controlGeneration
        Task {
            guard BookControlPlaybackRequestPolicy.shouldApplyDeletionReset(
                currentAsset: man.asset,
                deletedURLs: deletedURLs,
                currentGeneration: controlGeneration,
                requestGeneration: generation
            ) else {
                return
            }
            await man.reset(reason: "BookControlRootView.deletedCurrentAsset")
        }
    }

    func handleBookDBRefreshed(_ notification: Notification) {
        guard BookControlPlaybackRequestPolicy.shouldInvalidateChapterCacheAfterLibraryRefresh() else {
            return
        }

        BookControlChapterCache.removeAll()
    }

    func handleStorageLocationDidReset() {
        guard BookControlPlaybackRequestPolicy.shouldResetForStorageLocationChange(isSceneActive: shouldActivateControl) else {
            return
        }

        BookControlChapterCache.removeAll()

        let generation = controlGeneration
        Task {
            guard BookControlPlaybackRequestPolicy.shouldApplyStorageReset(
                currentGeneration: controlGeneration,
                requestGeneration: generation,
                isSceneActive: shouldActivateControl
            ) else {
                return
            }

            await man.reset(reason: "BookControlRootView.storageLocationDidReset")
        }
    }

    /// 处理上一章请求
    /// - Parameter asset: 当前播放的书籍章节资源
    func handlePreviousRequested(_ asset: URL) {
        guard shouldActivateControl else { return }

        if verbose {
            os_log("\(self.t)⏮️ Previous chapter requested")
        }

        let bookDisk = BookPlugin.getBookDisk()
        guard BookControlPlaybackRequestPolicy.shouldNavigateBookAsset(asset, bookDisk: bookDisk) else {
            return
        }

        let root = BookControlBookRootResolver.bookRoot(containing: asset, bookDisk: bookDisk)
        let playMode = man.playMode
        let generation = controlGeneration
        Task {
            let prev = await Self.adjacentAssetLoadingChapters(
                in: root,
                current: asset,
                offset: -1,
                playMode: playMode
            )

            if let prev {
                guard BookControlPlaybackRequestPolicy.shouldApplyNavigationResult(
                    requestedAsset: asset,
                    currentAsset: man.currentAsset,
                    isSceneActive: shouldActivateControl,
                    currentGeneration: controlGeneration,
                    requestGeneration: generation
                ) else {
                    return
                }
                await man.play(prev, reason: "handlePreviousRequested")
                if verbose {
                    os_log("\(self.t)✅ Playing previous chapter: \(prev.lastPathComponent)")
                }
            } else if verbose {
                os_log("\(self.t)⚠️ No previous chapter")
            }
        }
    }

    static func adjacentAssetLoadingChapters(
        in root: URL,
        current asset: URL,
        offset: Int,
        playMode: MagicPlayMode
    ) async -> URL? {
        if let chapters = BookControlChapterCache.cachedChapters(in: root) {
            return BookControlChapterLoader.adjacentAsset(
                in: chapters,
                current: asset,
                offset: offset,
                playMode: playMode
            )
        }

        let chapters = await Task.detached(priority: .userInitiated) {
            BookControlChapterLoader.playableChapters(in: root)
        }.value
        BookControlChapterCache.store(chapters, in: root)

        return BookControlChapterLoader.adjacentAsset(
            in: chapters,
            current: asset,
            offset: offset,
            playMode: playMode
        )
    }

    /// 处理下一章请求
    /// - Parameter asset: 当前播放的书籍章节资源
    func handleNextRequested(_ asset: URL) {
        guard shouldActivateControl else { return }

        if verbose {
            os_log("\(self.t)⏭️ Next chapter requested")
        }

        let bookDisk = BookPlugin.getBookDisk()
        guard BookControlPlaybackRequestPolicy.shouldNavigateBookAsset(asset, bookDisk: bookDisk) else {
            return
        }

        let root = BookControlBookRootResolver.bookRoot(containing: asset, bookDisk: bookDisk)
        let playMode = man.playMode
        let generation = controlGeneration
        Task {
            let next = await Self.adjacentAssetLoadingChapters(
                in: root,
                current: asset,
                offset: 1,
                playMode: playMode
            )

            if let next {
                guard BookControlPlaybackRequestPolicy.shouldApplyNavigationResult(
                    requestedAsset: asset,
                    currentAsset: man.currentAsset,
                    isSceneActive: shouldActivateControl,
                    currentGeneration: controlGeneration,
                    requestGeneration: generation
                ) else {
                    return
                }
                await man.play(next, reason: "handleNextRequested")
                if verbose {
                    os_log("\(self.t)✅ Playing next chapter: \(next.lastPathComponent)")
                }
            } else if verbose {
                os_log("\(self.t)⚠️ No next chapter")
            }
        }
    }
}

private extension Notification.Name {
    static let bookControlStorageLocationDidReset = Notification.Name("storageLocationDidReset")
}

extension BookControlRootView {
    nonisolated static func adjacentAsset(
        in chapters: [URL],
        current asset: URL,
        offset: Int,
        playMode: MagicPlayMode
    ) -> URL? {
        BookControlChapterLoader.adjacentAsset(
            in: chapters,
            current: asset,
            offset: offset,
            playMode: playMode
        )
    }

    @MainActor
    static func adjacentAssetLoadingChaptersForTesting(
        in root: URL,
        current asset: URL,
        offset: Int,
        playMode: MagicPlayMode
    ) async -> URL? {
        await adjacentAssetLoadingChapters(
            in: root,
            current: asset,
            offset: offset,
            playMode: playMode
        )
    }
}
