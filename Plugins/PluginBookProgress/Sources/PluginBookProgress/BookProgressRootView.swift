import Foundation
import MagicAlert
import MagicKit
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

    static func shouldResetGlobalTimeWhenCurrentURLChanges(from storedURL: URL?, to newURL: URL?) -> Bool {
        storedURL != newURL
    }

    static func snapshot(currentURL: URL?, currentTime: TimeInterval, trigger: BookProgressSaveTrigger) -> BookProgressStateSnapshot? {
        guard let currentURL else { return nil }

        switch trigger {
        case .currentURLChanged:
            return currentURLChangeSnapshot(currentURL: currentURL)
        case .playbackPositionChanged:
            return BookProgressStateSnapshot(currentURL: currentURL, time: currentTime)
        }
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

        guard isContained(url.path, in: disk.path) else {
            return parent
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

    private static func isContained(_ childPath: String, in parentPath: String) -> Bool {
        childPath == parentPath || childPath.hasPrefix(parentPath + "/")
    }
}

enum BookProgressBookLookup {
    static func bookURL(for currentURL: URL, bookDisk: URL?) -> URL? {
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

public struct BookProgressRootView<Content>: View, SuperLog where Content: View {
    public nonisolated static var emoji: String { BookProgressPluginInfo.emoji }
    private let verbose = true

    @EnvironmentObject private var man: MagicPlayMan
    @State private var playbackSubscriptionID: UUID?

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
            os_log("\(self.t)👀 视图已出现，开始恢复书籍进度")
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
        guard let playbackSubscriptionID else { return }

        persistCurrentProgress(reason: "deactivateProgress")
        man.unsubscribe(playbackSubscriptionID)
        self.playbackSubscriptionID = nil
    }

    /// 恢复书籍播放进度
    ///
    /// 从持久化存储中恢复上次播放的书籍和时间进度。
    private func restoreBookProgress() {
        Task {
            if let url = currentBookURL() {
                let isPlayable = isPlayableBookURL(url)

                guard isPlayable else {
                    if BookProgressPersistencePolicy.shouldClearRestoredCurrentURL(currentURL: url, isPlayable: isPlayable) {
                        storeCurrentBookURL(nil)
                    }

                    if self.verbose {
                        os_log("\(self.t)⚠️ 跳过已失效的书籍进度: \(url.shortPath())")
                    }
                    return
                }

                await man.play(url, autoPlay: false, startTime: currentBookTime(), reason: "restoreBookProgress")

                if self.verbose {
                    os_log("\(self.t)✅ 恢复书籍进度: \(url.lastPathComponent)")
                }
            }
        }
    }

    private func isPlayableBookURL(_ url: URL) -> Bool {
        FileManager.default.fileExists(atPath: url.path)
            && !url.isFolder
            && BookPluginInfo.supportedExtensions.contains(url.pathExtension.lowercased())
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
                os_log("\(self.t)📖 URL 已清空")
            }

            storeCurrentBookURL(nil)
            if BookProgressPersistencePolicy.shouldResetGlobalTimeWhenCurrentURLChanges(from: storedURL, to: nil) {
                storeCurrentBookTime(0)
            }
            return
        }

        let url = snapshot.currentURL

        if self.verbose {
            os_log("\(self.t)📖 URL变化 -> \(url.shortPath())")
        }

        Task {
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
                    if self.verbose {
                        os_log("\(self.t)✅ 书籍文件下载完成")
                    }
                } catch let error {
                    os_log(.error, "\(self.t)❌ 书籍文件下载失败: \(error.localizedDescription)")
                    alert_error(String(localized: "Download failed: \(error.localizedDescription)", table: "Book-Progress", bundle: .module))
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

    private func persistCurrentProgress(reason: String) {
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
            os_log("\(self.t)💾 (\(reason)) 保存书籍播放时间: \(snapshot.time ?? 0)s")
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
                os_log("\(self.t)⚠️ 无法找到 \(currentURL.lastPathComponent) 所属的书籍")
            }
            return
        }

        // 更新书籍状态（保存当前章节和时间）
        if self.verbose {
            if let time {
                os_log("\(self.t)💾 保存书籍状态: \(bookURL.lastPathComponent) -> \(currentURL.lastPathComponent) @ \(time)s")
            } else {
                os_log("\(self.t)💾 保存书籍当前章节: \(bookURL.lastPathComponent) -> \(currentURL.lastPathComponent)")
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
                os_log("\(self.t)⚠️ 无法读取目录内容: \(error.localizedDescription)")
            }

            os_log("\(self.t)⚠️ 父路径不是书籍目录: \(parentURL.shortPath())")
        }

        return nil
    }

    private func bookRoot(containing url: URL) -> URL {
        BookProgressBookRootResolver.bookRoot(containing: url, bookDisk: BookPlugin.getBookDisk())
    }
}
