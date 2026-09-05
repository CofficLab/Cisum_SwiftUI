import Foundation
import MagicAlert
import MagicKit
import MagicPlayMan
import OSLog
import PluginBook
import ProviderScene
import SwiftUI

/// 书籍播放进度的集中状态容器（迁移 Phase 5）。
///
/// 持有播放订阅、恢复代际与场景激活状态，统一处理进度恢复、URL变化持久化、
/// 暂停保存与删除清理；取代原 `BookProgressRootView` 内的全部
/// `@State` 与事件 handler。由 `BookProgressPlugin` 入口持有。
///
/// ViewModel 不直接持有 Kernel 或具体 Provider：外部播放状态由
/// `BookProgressObserver` 通过事件回写，外部播放操作通过
/// `BookProgressPlaybackCapability` 执行。
@MainActor
final class BookProgressViewModel: ObservableObject, SuperLog {
    private static let verbose = true
    private static let log = Logger(subsystem: "com.yueyi.cisum", category: "BookProgress")
    private static let tag = "📖"

    private let playbackCapability: (any BookProgressPlaybackCapability)?
    private var restoreGeneration = 0
    private var currentScene: AppScene?
    private let targetScene: AppScene

    private let currentBookURL: BookProgressURLProvider
    private let currentBookTime: BookProgressTimeProvider
    private let storeCurrentBookURL: BookProgressStoreCurrentURL
    private let storeCurrentBookTime: BookProgressStoreCurrentTime
    private let saveBookState: BookProgressSaveBookState

    init(
        targetScene: AppScene,
        playbackCapability: (any BookProgressPlaybackCapability)?,
        currentBookURL: @escaping BookProgressURLProvider,
        currentBookTime: @escaping BookProgressTimeProvider,
        storeCurrentBookURL: @escaping BookProgressStoreCurrentURL,
        storeCurrentBookTime: @escaping BookProgressStoreCurrentTime,
        saveBookState: @escaping BookProgressSaveBookState
    ) {
        self.targetScene = targetScene
        self.playbackCapability = playbackCapability
        self.currentBookURL = currentBookURL
        self.currentBookTime = currentBookTime
        self.storeCurrentBookURL = storeCurrentBookURL
        self.storeCurrentBookTime = storeCurrentBookTime
        self.saveBookState = saveBookState
    }

    var shouldActivateProgress: Bool {
        currentScene == targetScene
    }

    // MARK: - Scene activation

    func handleSceneChange(_ sceneValue: AppScene?) {
        currentScene = sceneValue
        if sceneValue == targetScene {
            activateProgress()
        } else {
            deactivateProgress()
        }
    }

    private func activateProgress() {
        guard shouldActivateProgress else { return }

        if Self.verbose {
            Self.log.debug("\(Self.tag)👀 View appeared, restoring audiobook progress")
        }

        restoreBookProgress()

        guard playbackCapability != nil else { return }
    }

    private func deactivateProgress() {
        restoreGeneration += 1

        persistCurrentProgress(reason: "deactivateProgress")
    }

    // MARK: - Restore

    private func restoreBookProgress() {
        guard let playback = playbackCapability else { return }
        let startingAsset = playback.currentAsset
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

                    if Self.verbose {
                        Self.log.debug("\(Self.tag)⚠️ Skipping stale audiobook progress: \(url.shortPath())")
                    }
                    return
                }

                guard BookProgressPersistencePolicy.shouldApplyRestoreResult(
                    startingAsset: startingAsset,
                    currentAsset: playback.currentAsset
                ) else { return }

                if BookProgressPersistencePolicy.shouldPlayRestoredAsset(
                    restoredAsset: url,
                    currentAsset: playback.currentAsset
                ) {
                    guard isCurrentRestoreRequest(generation) else { return }
                    await playback.play(url, autoPlay: false, startTime: currentBookTime() ?? 0, reason: "restoreBookProgress")
                }

                if Self.verbose {
                    Self.log.debug("\(Self.tag)✅ Restored audiobook progress: \(url.lastPathComponent)")
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

    // MARK: - URL change & persistence

    func handleCurrentURLChanged(_ url: URL?) {
        guard shouldActivateProgress else { return }
        guard let playback = playbackCapability else { return }

        let storedURL = currentBookURL()

        guard let snapshot = BookProgressPersistencePolicy.currentURLChangeSnapshot(currentURL: url) else {
            if Self.verbose {
                Self.log.debug("\(Self.tag)📖 URL cleared")
            }

            storeCurrentBookURL(nil)
            if BookProgressPersistencePolicy.shouldResetGlobalTimeWhenCurrentURLChanges(from: storedURL, to: nil) {
                storeCurrentBookTime(0)
            }
            return
        }

        let url = snapshot.currentURL
        let bookDisk = BookPlugin.getBookDisk()

        if Self.verbose {
            Self.log.debug("\(Self.tag)📖 URL changed -> \(url.shortPath())")
        }

        let generation = restoreGeneration
        Task {
            guard BookProgressPersistencePolicy.shouldApplyCurrentURLChange(
                requestedURL: snapshot.currentURL,
                currentAsset: playback.currentAsset,
                currentGeneration: restoreGeneration,
                requestGeneration: generation,
                isSceneActive: shouldActivateProgress
            ) else { return }

            guard BookProgressPersistencePolicy.shouldPersistCurrentURLChange(from: storedURL, to: url) else { return }

            guard BookProgressPersistencePolicy.shouldAcceptBookURL(url, bookDisk: bookDisk) else {
                if Self.verbose {
                    Self.log.debug("\(Self.tag)⚠️ Skipping audio outside the audiobook library: \(url.shortPath())")
                }
                return
            }

            storeCurrentBookURL(url)
            if BookProgressPersistencePolicy.shouldResetGlobalTimeWhenCurrentURLChanges(from: storedURL, to: url) {
                storeCurrentBookTime(0)
            }

            await saveBookState(currentURL: snapshot.currentURL, time: snapshot.time)

            if url.isNotDownloaded {
                do {
                    try await url.download(reason: "BookProgressViewModel")
                    guard BookProgressPersistencePolicy.shouldApplyCurrentURLChange(
                        requestedURL: snapshot.currentURL,
                        currentAsset: playback.currentAsset,
                        currentGeneration: restoreGeneration,
                        requestGeneration: generation,
                        isSceneActive: shouldActivateProgress
                    ) else { return }
                    if Self.verbose {
                        Self.log.debug("\(Self.tag)✅ Audiobook file download completed")
                    }
                } catch {
                    guard BookProgressPersistencePolicy.shouldApplyCurrentURLChange(
                        requestedURL: snapshot.currentURL,
                        currentAsset: playback.currentAsset,
                        currentGeneration: restoreGeneration,
                        requestGeneration: generation,
                        isSceneActive: shouldActivateProgress
                    ) else { return }
                    Self.log.error("\(Self.tag)❌ Audiobook file download failed: \(error.localizedDescription)")
                    alert_error(String(localized: "Download failed: \(error.localizedDescription)", bundle: .module))
                }
            }
        }
    }

    func handlePlayManStateChanged(_ isPlaying: Bool) {
        guard shouldActivateProgress, let playback = playbackCapability, playback.state == .paused else { return }

        persistCurrentProgress(reason: "handlePlayManStateChanged")
    }

    func handleBookDBDeleted(deletedURLs: [URL]) {
        guard BookProgressPersistencePolicy.shouldClearStoredCurrentAfterDelete(
            storedURL: currentBookURL(),
            deletedURLs: deletedURLs
        ) else { return }

        storeCurrentBookURL(nil)
        storeCurrentBookTime(0)
    }

    private func persistCurrentProgress(reason: String) {
        guard let playback = playbackCapability else { return }
        guard BookProgressPersistencePolicy.shouldPersistPlaybackProgress(
            currentURL: playback.currentAsset,
            bookDisk: BookPlugin.getBookDisk()
        ) else { return }

        guard let snapshot = BookProgressPersistencePolicy.snapshot(
            currentURL: playback.currentAsset,
            currentTime: playback.currentTime,
            trigger: .playbackPositionChanged
        ) else { return }

        storeCurrentBookTime(snapshot.time ?? 0)

        Task {
            await saveBookState(currentURL: snapshot.currentURL, time: snapshot.time)
        }

        if Self.verbose {
            Self.log.debug("\(Self.tag)💾 (\(reason)) Saved audiobook playback time: \(snapshot.time ?? 0)s")
        }
    }

    private func saveBookState(currentURL: URL, time: TimeInterval?) async {
        guard let bookURL = await findBookForURL(currentURL) else {
            if Self.verbose {
                Self.log.debug("\(Self.tag)⚠️ Could not find the audiobook for \(currentURL.lastPathComponent)")
            }
            return
        }

        if Self.verbose {
            if let time {
                Self.log.debug("\(Self.tag)💾 Saved audiobook state: \(bookURL.lastPathComponent) -> \(currentURL.lastPathComponent) @ \(time)s")
            } else {
                Self.log.debug("\(Self.tag)💾 Saved audiobook current chapter: \(bookURL.lastPathComponent) -> \(currentURL.lastPathComponent)")
            }
        }

        await saveBookState(bookURL, currentURL, time)
    }

    private func findBookForURL(_ url: URL) async -> URL? {
        if let bookURL = BookProgressBookLookup.bookURL(for: url, bookDisk: BookPlugin.getBookDisk()) {
            return bookURL
        }

        if Self.verbose {
            let parentURL = bookRoot(containing: url)
            do {
                _ = try FileManager.default.contentsOfDirectory(at: parentURL, includingPropertiesForKeys: nil)
            } catch {
                Self.log.debug("\(Self.tag)⚠️ Could not read directory contents: \(error.localizedDescription)")
            }

            Self.log.debug("\(Self.tag)⚠️ Parent path is not an audiobook directory: \(parentURL.shortPath())")
        }

        return nil
    }

    private func bookRoot(containing url: URL) -> URL {
        BookProgressBookRootResolver.bookRoot(containing: url, bookDisk: BookPlugin.getBookDisk())
    }
}
