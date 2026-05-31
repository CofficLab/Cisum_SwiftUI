import Foundation
import MagicKit
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

enum BookControlPlaybackRequestPolicy {
    static func shouldApplyNavigationResult(requestedAsset: URL, currentAsset: URL?) -> Bool {
        currentAsset == requestedAsset
    }

    static func currentAssetAffectedByDeletion(currentAsset: URL?, deletedURLs: [URL]) -> Bool {
        guard let currentAsset else { return false }
        return deletedURLs.contains { deletedURL in
            let parentPath = resolvedStandardizedPath(for: deletedURL)
            let assetPath = resolvedStandardizedPath(for: currentAsset)
            return isContained(assetPath, in: parentPath)
        }
    }

    private static func resolvedStandardizedPath(for url: URL) -> String {
        url.resolvingSymlinksInPath().standardizedFileURL.path
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
        root
            .flatten()
            .filter { url in
                !url.isFolder
                    && FileManager.default.fileExists(atPath: url.path)
                    && BookPluginInfo.supportedExtensions.contains(url.pathExtension.lowercased())
            }
            .sorted {
                relativePath($0, in: root).localizedStandardCompare(relativePath($1, in: root)) == .orderedAscending
            }
    }

    static func adjacentAsset(
        in chapters: [URL],
        current asset: URL,
        offset: Int,
        playMode: MagicPlayMode
    ) -> URL? {
        guard !chapters.isEmpty, let index = chapters.firstIndex(of: asset) else { return nil }

        let adjacentIndex = index + offset
        if chapters.indices.contains(adjacentIndex) {
            return chapters[adjacentIndex]
        }

        switch playMode {
        case .repeatAll:
            return offset > 0 ? chapters.first : chapters.last
        case .shuffle:
            return chapters.filter { $0 != asset }.randomElement() ?? chapters.first
        case .sequence, .loop:
            return nil
        }
    }
}

public struct BookControlRootView<Content>: View, SuperLog where Content: View {
    public nonisolated static var emoji: String { BookControlPluginInfo.emoji }
    private let verbose = false

    @EnvironmentObject private var man: MagicPlayMan
    @State private var playbackSubscriptionID: UUID?

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

private extension BookControlRootView {
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
                os_log("\(self.t)⏭️ 书籍播放控制跳过：当前场景不是书籍场景")
            }
            return
        }

        if verbose {
            os_log("\(self.t)👀 视图已出现，开始初始化书籍播放控制")
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
        let root = bookRoot(containing: asset)
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
        guard let deletedURLs = notification.userInfo?["urls"] as? [URL],
              BookControlPlaybackRequestPolicy.currentAssetAffectedByDeletion(
                  currentAsset: man.asset,
                  deletedURLs: deletedURLs
              ) else {
            return
        }

        Task {
            guard BookControlPlaybackRequestPolicy.currentAssetAffectedByDeletion(
                currentAsset: man.asset,
                deletedURLs: deletedURLs
            ) else {
                return
            }
            await man.reset(reason: "BookControlRootView.deletedCurrentAsset")
        }
    }

    func handleStorageLocationDidReset() {
        Task {
            await man.reset(reason: "BookControlRootView.storageLocationDidReset")
        }
    }

    /// 处理上一章请求
    /// - Parameter asset: 当前播放的书籍章节资源
    func handlePreviousRequested(_ asset: URL) {
        guard shouldActivateControl else { return }

        if verbose {
            os_log("\(self.t)⏮️ 请求上一章")
        }

        let root = bookRoot(containing: asset)
        let playMode = man.playMode
        Task {
            let prev = await Task.detached(priority: .userInitiated) {
                let chapters = BookControlChapterLoader.playableChapters(in: root)
                return BookControlChapterLoader.adjacentAsset(
                    in: chapters,
                    current: asset,
                    offset: -1,
                    playMode: playMode
                )
            }.value

            if let prev {
                guard BookControlPlaybackRequestPolicy.shouldApplyNavigationResult(
                    requestedAsset: asset,
                    currentAsset: man.currentAsset
                ) else {
                    return
                }
                await man.play(prev, reason: "handlePreviousRequested")
                if verbose {
                    os_log("\(self.t)✅ 播放上一章: \(prev.lastPathComponent)")
                }
            } else if verbose {
                os_log("\(self.t)⚠️ 没有上一章")
            }
        }
    }

    /// 处理下一章请求
    /// - Parameter asset: 当前播放的书籍章节资源
    func handleNextRequested(_ asset: URL) {
        guard shouldActivateControl else { return }

        if verbose {
            os_log("\(self.t)⏭️ 请求下一章")
        }

        let root = bookRoot(containing: asset)
        let playMode = man.playMode
        Task {
            let next = await Task.detached(priority: .userInitiated) {
                let chapters = BookControlChapterLoader.playableChapters(in: root)
                return BookControlChapterLoader.adjacentAsset(
                    in: chapters,
                    current: asset,
                    offset: 1,
                    playMode: playMode
                )
            }.value

            if let next {
                guard BookControlPlaybackRequestPolicy.shouldApplyNavigationResult(
                    requestedAsset: asset,
                    currentAsset: man.currentAsset
                ) else {
                    return
                }
                await man.play(next, reason: "handleNextRequested")
                if verbose {
                    os_log("\(self.t)✅ 播放下一章: \(next.lastPathComponent)")
                }
            } else if verbose {
                os_log("\(self.t)⚠️ 没有下一章")
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
}
