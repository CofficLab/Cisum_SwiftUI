import Foundation
import CisumUIComponents
import MagicPlayMan
import OSLog
import PluginBook
import SwiftUI

public typealias BookProgressCurrentSceneProvider = @MainActor () -> String?
public typealias BookProgressURLProvider = @MainActor () -> URL?
public typealias BookProgressTimeProvider = @MainActor () -> TimeInterval?
public typealias BookProgressStoreCurrentURL = @MainActor (URL?) -> Void
public typealias BookProgressStoreCurrentTime = @MainActor (TimeInterval) -> Void
public typealias BookProgressSaveBookState = @Sendable (URL, URL, TimeInterval?) async -> Void

enum BookProgressSaveTrigger {
    case currentURLChanged
    case playbackPositionChanged
}

struct BookProgressStateSnapshot: Equatable {
    let currentURL: URL
    let time: TimeInterval?
}

enum BookProgressPersistencePolicy {
    static func currentURLChangeSnapshot(currentURL: URL?) -> BookProgressStateSnapshot? {
        guard let currentURL else { return nil }

        return BookProgressStateSnapshot(currentURL: currentURL, time: nil)
    }

    static func shouldClearRestoredCurrentURL(currentURL: URL?, isPlayable: Bool) -> Bool {
        currentURL != nil && !isPlayable
    }

    static func shouldClearRestoredCurrentTime(currentURL: URL?, isPlayable: Bool) -> Bool {
        shouldClearRestoredCurrentURL(currentURL: currentURL, isPlayable: isPlayable)
    }

    static func shouldClearStoredCurrentAfterDelete(storedURL: URL?, deletedURLs: [URL]) -> Bool {
        guard let storedURL else { return false }
        let storedPaths = BookProgressFileLocationIdentity.containmentPaths(for: storedURL)
        return deletedURLs.contains { deletedURL in
            BookProgressFileLocationIdentity.containmentPaths(for: deletedURL).contains { deletedPath in
                storedPaths.contains { storedPath in
                    storedPath == deletedPath
                        || storedPath.hasPrefix(BookProgressPathContainment.childPrefix(for: deletedPath))
                }
            }
        }
    }

    static func shouldResetGlobalTimeWhenCurrentURLChanges(from storedURL: URL?, to newURL: URL?) -> Bool {
        !representsSameFile(storedURL, newURL)
    }

    static func shouldPersistCurrentURLChange(from storedURL: URL?, to newURL: URL?) -> Bool {
        !representsSameFile(storedURL, newURL)
    }

    static func shouldAcceptBookURL(_ url: URL, bookDisk: URL?) -> Bool {
        BookProgressBookLookup.bookURL(for: url, bookDisk: bookDisk) != nil
    }

    static func shouldPersistPlaybackProgress(currentURL: URL?, bookDisk: URL?) -> Bool {
        guard let currentURL else { return false }

        return shouldAcceptBookURL(currentURL, bookDisk: bookDisk)
    }

    static func snapshot(currentURL: URL?, currentTime: TimeInterval, trigger: BookProgressSaveTrigger) -> BookProgressStateSnapshot? {
        guard let currentURL else { return nil }

        switch trigger {
        case .currentURLChanged:
            return currentURLChangeSnapshot(currentURL: currentURL)
        case .playbackPositionChanged:
            return BookProgressStateSnapshot(currentURL: currentURL, time: normalizedPlaybackTime(currentTime))
        }
    }

    static func shouldApplyRestoreResult(startingAsset: URL?, currentAsset: URL?) -> Bool {
        representsSameFile(startingAsset, currentAsset)
    }

    static func shouldApplyRestoreRequest(currentGeneration: Int, requestGeneration: Int, isSceneActive: Bool) -> Bool {
        currentGeneration == requestGeneration && isSceneActive
    }

    static func shouldPlayRestoredAsset(restoredAsset: URL, currentAsset: URL?) -> Bool {
        !representsSameFile(restoredAsset, currentAsset)
    }

    static func shouldApplyCurrentURLChange(requestedURL: URL, currentAsset: URL?) -> Bool {
        representsSameFile(requestedURL, currentAsset)
    }

    static func shouldApplyCurrentURLChange(
        requestedURL: URL,
        currentAsset: URL?,
        currentGeneration: Int,
        requestGeneration: Int,
        isSceneActive: Bool
    ) -> Bool {
        currentGeneration == requestGeneration
            && isSceneActive
            && shouldApplyCurrentURLChange(requestedURL: requestedURL, currentAsset: currentAsset)
    }

    private static func representsSameFile(_ lhs: URL?, _ rhs: URL?) -> Bool {
        BookProgressFileLocationIdentity.representsSameFile(lhs, rhs)
    }

    private static func normalizedPlaybackTime(_ time: TimeInterval) -> TimeInterval {
        guard time.isFinite, time > 0 else { return 0 }
        return time
    }
}

enum BookProgressFileLocationIdentity {
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

enum BookProgressBookRootResolver {
    static func bookRoot(containing url: URL, bookDisk: URL?) -> URL {
        let parent = url.deletingLastPathComponent().standardizedFileURL

        guard let bookDisk else {
            return parent
        }

        let disk = bookDisk.standardizedFileURL
        let url = url.standardizedFileURL

        guard BookProgressPathContainment.resolved(url, isContainedIn: disk) else {
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
        let resolvedURLPath = BookProgressPathContainment.resolvedStandardizedPath(for: url)
        let resolvedDiskPath = BookProgressPathContainment.resolvedStandardizedPath(for: disk)

        guard let relativePath = BookProgressPathContainment.relativePath(of: resolvedURLPath, in: resolvedDiskPath),
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
        childPath == parentPath || childPath.hasPrefix(BookProgressPathContainment.childPrefix(for: parentPath))
    }
}

enum BookProgressBookLookup {
    static func bookURL(for currentURL: URL, bookDisk: URL?) -> URL? {
        if let bookDisk, !BookProgressPathContainment.resolved(currentURL, isContainedIn: bookDisk) {
            return nil
        }

        let bookURL = BookProgressBookRootResolver.bookRoot(containing: currentURL, bookDisk: bookDisk)

        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: bookURL.path, isDirectory: &isDirectory) else {
            return nil
        }

        if isDirectory.boolValue {
            return bookURL
        }

        return BookPluginInfo.supportedExtensions.contains(bookURL.pathExtension.lowercased()) ? bookURL : nil
    }

}

enum BookProgressPathContainment {
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

        let prefix = childPrefix(for: parentPath)
        guard childPath.hasPrefix(prefix) else {
            return nil
        }

        return String(childPath.dropFirst(prefix.count))
    }

    private static func isContained(_ childPath: String, in parentPath: String) -> Bool {
        childPath == parentPath || childPath.hasPrefix(childPrefix(for: parentPath))
    }

    static func childPrefix(for parentPath: String) -> String {
        parentPath.hasSuffix("/") ? parentPath : parentPath + "/"
    }
}

public struct BookProgressRootView<Content>: View, SuperLog where Content: View {
    public nonisolated static var emoji: String { BookProgressPluginInfo.emoji }
    private let verbose = true

    @EnvironmentObject private var man: MagicPlayMan
    @State private var playbackSubscriptionID: UUID?
    @State private var restoreGeneration = 0

    private let content: Content
    private let targetSceneName: String
    private let currentSceneName: BookProgressCurrentSceneProvider
    private let currentBookURL: BookProgressURLProvider
    private let currentBookTime: BookProgressTimeProvider
    private let storeCurrentBookURL: BookProgressStoreCurrentURL
    private let storeCurrentBookTime: BookProgressStoreCurrentTime
    private let saveBookState: BookProgressSaveBookState

    public init(
        targetSceneName: String,
        currentSceneName: @escaping BookProgressCurrentSceneProvider,
        currentBookURL: @escaping BookProgressURLProvider,
        currentBookTime: @escaping BookProgressTimeProvider,
        storeCurrentBookURL: @escaping BookProgressStoreCurrentURL,
        storeCurrentBookTime: @escaping BookProgressStoreCurrentTime,
        saveBookState: @escaping BookProgressSaveBookState,
        @ViewBuilder content: () -> Content
    ) {
        self.targetSceneName = targetSceneName
        self.currentSceneName = currentSceneName
        self.currentBookURL = currentBookURL
        self.currentBookTime = currentBookTime
        self.storeCurrentBookURL = storeCurrentBookURL
        self.storeCurrentBookTime = storeCurrentBookTime
        self.saveBookState = saveBookState
        self.content = content()
    }

    public var body: some View {
        content
            .onAppear(perform: handleOnAppear)
            .onDisappear(perform: handleOnDisappear)
            .onChange(of: currentSceneName()) { _, newSceneName in
                handleCurrentSceneChanged(newSceneName)
            }
            .onPlayManStateChanged(handlePlayManStateChanged)
            .onReceive(NotificationCenter.default.publisher(for: .bookDBDeleted), perform: handleBookDBDeleted)
    }

    /// 检查是否应该激活书籍进度管理功能
    private var shouldActivateProgress: Bool {
        currentSceneName() == targetSceneName
    }
}

// MARK: - Action

private extension BookProgressRootView {
    /// 处理视图出现事件
    ///
    /// 当视图首次出现时触发，恢复上次播放的书籍和进度。
    func handleOnAppear() {
        updateProgressActivation(for: currentSceneName())
    }

    /// 处理视图消失事件，释放播放器事件订阅。
    func handleOnDisappear() {
        deactivateProgress()
    }

    /// 处理当前场景变化，确保从其它场景切到书籍场景时也能恢复并保存进度。
    func handleCurrentSceneChanged(_ sceneName: String?) {
        updateProgressActivation(for: sceneName)
    }

    private func updateProgressActivation(for sceneName: String?) {
        if sceneName == targetSceneName {
            activateProgress()
        } else {
            deactivateProgress()
        }
    }

    private func activateProgress() {
        guard shouldActivateProgress else {
            return
        }

        if verbose {
            os_log("\(self.t)👀 View appeared, restoring audiobook progress")
        }

        restoreBookProgress()

        // 订阅播放器事件，监听URL变化
        guard playbackSubscriptionID == nil else { return }

        playbackSubscriptionID = man.subscribe(
            name: "BookProgressPlugin",
            onCurrentURLChanged: { url in
                handleCurrentURLChanged(url)
            }
        )
    }

    private func deactivateProgress() {
        restoreGeneration += 1

        guard let playbackSubscriptionID else { return }

        persistCurrentProgress(reason: "deactivateProgress")
        man.unsubscribe(playbackSubscriptionID)
        self.playbackSubscriptionID = nil
    }

    /// 恢复书籍播放进度
    ///
    /// 从持久化存储中恢复上次播放的书籍和时间进度。
    private func restoreBookProgress() {
        let startingAsset = man.currentAsset
        restoreGeneration += 1
        let generation = restoreGeneration

        Task { @MainActor in
            guard isCurrentRestoreRequest(generation) else { return }

            if let url = currentBookURL() {
                let isPlayable = isPlayableBookURL(url)

                guard isPlayable else {
                    if BookProgressPersistencePolicy.shouldClearRestoredCurrentURL(currentURL: url, isPlayable: isPlayable) {
                        storeCurrentBookURL(nil)
                    }
                    if BookProgressPersistencePolicy.shouldClearRestoredCurrentTime(currentURL: url, isPlayable: isPlayable) {
                        storeCurrentBookTime(0)
                    }

                    if self.verbose {
                        os_log("\(self.t)⚠️ Skipping stale audiobook progress: \(url.shortPath())")
                    }
                    return
                }

                guard BookProgressPersistencePolicy.shouldApplyRestoreResult(
                    startingAsset: startingAsset,
                    currentAsset: man.currentAsset
                ) else {
                    return
                }

                if BookProgressPersistencePolicy.shouldPlayRestoredAsset(
                    restoredAsset: url,
                    currentAsset: man.currentAsset
                ) {
                    guard isCurrentRestoreRequest(generation) else { return }
                    await man.play(url, autoPlay: false, startTime: currentBookTime(), reason: "restoreBookProgress")
                }

                if self.verbose {
                    os_log("\(self.t)✅ Restored audiobook progress: \(url.lastPathComponent)")
                }
            }
        }
    }

    private func isCurrentRestoreRequest(_ generation: Int) -> Bool {
        BookProgressPersistencePolicy.shouldApplyRestoreRequest(
            currentGeneration: restoreGeneration,
            requestGeneration: generation,
            isSceneActive: shouldActivateProgress
        )
    }

    private func isPlayableBookURL(_ url: URL) -> Bool {
        BookProgressPersistencePolicy.shouldAcceptBookURL(url, bookDisk: BookPlugin.getBookDisk())
    }

    /// 处理当前URL变化事件
    ///
    /// 当播放的URL改变时，保存书籍的播放进度。
    ///
    /// - Parameter url: 新的播放URL，nil 表示播放器已清空当前资源
    func handleCurrentURLChanged(_ url: URL?) {
        guard shouldActivateProgress else { return }

        let storedURL = currentBookURL()

        guard let snapshot = BookProgressPersistencePolicy.currentURLChangeSnapshot(currentURL: url) else {
            if self.verbose {
                os_log("\(self.t)📖 URL cleared")
            }

            storeCurrentBookURL(nil)
            if BookProgressPersistencePolicy.shouldResetGlobalTimeWhenCurrentURLChanges(from: storedURL, to: nil) {
                storeCurrentBookTime(0)
            }
            return
        }

        let url = snapshot.currentURL
        let bookDisk = BookPlugin.getBookDisk()

        if self.verbose {
            os_log("\(self.t)📖 URL changed -> \(url.shortPath())")
        }

        let generation = restoreGeneration
        Task {
            guard BookProgressPersistencePolicy.shouldApplyCurrentURLChange(
                requestedURL: snapshot.currentURL,
                currentAsset: man.currentAsset,
                currentGeneration: restoreGeneration,
                requestGeneration: generation,
                isSceneActive: shouldActivateProgress
            ) else {
                return
            }

            guard BookProgressPersistencePolicy.shouldPersistCurrentURLChange(from: storedURL, to: url) else {
                return
            }

            guard BookProgressPersistencePolicy.shouldAcceptBookURL(url, bookDisk: bookDisk) else {
                if self.verbose {
                    os_log("\(self.t)⚠️ Skipping audio outside the audiobook library: \(url.shortPath())")
                }
                return
            }

            // 保存全局状态（用于应用启动恢复）
            storeCurrentBookURL(url)
            if BookProgressPersistencePolicy.shouldResetGlobalTimeWhenCurrentURLChanges(from: storedURL, to: url) {
                storeCurrentBookTime(0)
            }

            // URL 变化只保存当前章节，避免恢复播放时把已有时间覆盖成 0。
            await saveBookState(currentURL: snapshot.currentURL, time: snapshot.time)

            // 如果文件未下载，自动下载
            if url.isNotDownloaded {
                do {
                    try await url.download(reason: "BookProgressRootView")
                    guard BookProgressPersistencePolicy.shouldApplyCurrentURLChange(
                        requestedURL: snapshot.currentURL,
                        currentAsset: man.currentAsset,
                        currentGeneration: restoreGeneration,
                        requestGeneration: generation,
                        isSceneActive: shouldActivateProgress
                    ) else {
                        return
                    }
                    if self.verbose {
                        os_log("\(self.t)✅ Audiobook file download completed")
                    }
                } catch let error {
                    guard BookProgressPersistencePolicy.shouldApplyCurrentURLChange(
                        requestedURL: snapshot.currentURL,
                        currentAsset: man.currentAsset,
                        currentGeneration: restoreGeneration,
                        requestGeneration: generation,
                        isSceneActive: shouldActivateProgress
                    ) else {
                        return
                    }
                    os_log(.error, "\(self.t)❌ Audiobook file download failed: \(error.localizedDescription)")
                    alert_error(String(localized: "Download failed: \(error.localizedDescription)", bundle: .module))
                }
            }
        }
    }

    /// 处理播放器状态变化事件。
    ///
    /// 暂停时保存全局播放时间和当前书籍的独立进度，保证下次进入书籍场景能恢复到准确位置。
    func handlePlayManStateChanged(_ isPlaying: Bool) {
        guard shouldActivateProgress else { return }
        guard man.state == .paused else { return }

        persistCurrentProgress(reason: "handlePlayManStateChanged")
    }

    func handleBookDBDeleted(_ notification: Notification) {
        guard let deletedURLs = notification.userInfo?["urls"] as? [URL],
              BookProgressPersistencePolicy.shouldClearStoredCurrentAfterDelete(
                  storedURL: currentBookURL(),
                  deletedURLs: deletedURLs
              ) else {
            return
        }

        storeCurrentBookURL(nil)
        storeCurrentBookTime(0)
    }

    private func persistCurrentProgress(reason: String) {
        guard BookProgressPersistencePolicy.shouldPersistPlaybackProgress(
            currentURL: man.currentAsset,
            bookDisk: BookPlugin.getBookDisk()
        ) else {
            return
        }

        guard let snapshot = BookProgressPersistencePolicy.snapshot(
            currentURL: man.currentAsset,
            currentTime: man.currentTime,
            trigger: .playbackPositionChanged
        ) else {
            return
        }

        storeCurrentBookTime(snapshot.time ?? 0)

        Task {
            await saveBookState(currentURL: snapshot.currentURL, time: snapshot.time)
        }

        if self.verbose {
            os_log("\(self.t)💾 (\(reason)) Saved audiobook playback time: \(snapshot.time ?? 0)s")
        }
    }

    /// 保存书籍状态
    ///
    /// 保存当前书籍的播放进度到 BookState 模型。
    ///
    /// - Parameter currentURL: 当前播放的URL
    private func saveBookState(currentURL: URL, time: TimeInterval?) async {
        // 找到当前URL所属的书籍
        guard let bookURL = await findBookForURL(currentURL) else {
            if self.verbose {
                os_log("\(self.t)⚠️ Could not find the audiobook for \(currentURL.lastPathComponent)")
            }
            return
        }

        // 更新书籍状态（保存当前章节和时间）
        if self.verbose {
            if let time {
                os_log("\(self.t)💾 Saved audiobook state: \(bookURL.lastPathComponent) -> \(currentURL.lastPathComponent) @ \(time)s")
            } else {
                os_log("\(self.t)💾 Saved audiobook current chapter: \(bookURL.lastPathComponent) -> \(currentURL.lastPathComponent)")
            }
        }

        await saveBookState(bookURL, currentURL, time)
    }

    /// 查找URL所属的书籍
    ///
    /// - Parameter url: 要查找的URL
    /// - Returns: 所属书籍的URL，如果未找到则返回nil
    private func findBookForURL(_ url: URL) async -> URL? {
        if let bookURL = BookProgressBookLookup.bookURL(for: url, bookDisk: BookPlugin.getBookDisk()) {
            return bookURL
        }

        if self.verbose {
            let parentURL = bookRoot(containing: url)
            do {
                _ = try FileManager.default.contentsOfDirectory(at: parentURL, includingPropertiesForKeys: nil)
            } catch {
                os_log("\(self.t)⚠️ Could not read directory contents: \(error.localizedDescription)")
            }

            os_log("\(self.t)⚠️ Parent path is not an audiobook directory: \(parentURL.shortPath())")
        }

        return nil
    }

    private func bookRoot(containing url: URL) -> URL {
        BookProgressBookRootResolver.bookRoot(containing: url, bookDisk: BookPlugin.getBookDisk())
    }
}
