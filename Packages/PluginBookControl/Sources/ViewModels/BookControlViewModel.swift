import Foundation
import MagicPlayMan
import OSLog
import PluginBook
import ProviderPlayback
import ProviderScene
import SwiftUI

/// 书籍播放控制的集中状态容器（迁移 Phase 5）。
///
/// 持有播放订阅、代际保护与场景激活状态，统一处理上一章/下一章、
/// 删除恢复、章节缓存失效与存储重置；取代原 `BookControlRootView`
/// 内的全部 `@State` 与事件 handler。由 `BookControlPlugin` 入口持有。
@MainActor
final class BookControlViewModel: ObservableObject {
    private static let verbose = false
    private static let log = Logger(subsystem: "com.yueyi.cisum", category: "BookControl")
    private static let tag = "⏭️"

    private weak var playMan: MagicPlayMan?
    private var controlGeneration = 0
    private var currentScene: AppScene?
    private let targetScene: AppScene

    init(targetScene: AppScene) {
        self.targetScene = targetScene
    }

    func bind(playMan: MagicPlayMan?) {
        self.playMan = playMan
    }

    var shouldActivateControl: Bool {
        currentScene == targetScene
    }

    // MARK: - Scene activation

    func handleSceneChange(_ sceneValue: AppScene?) {
        currentScene = sceneValue
        if sceneValue == targetScene {
            activateControl()
        } else {
            deactivateControl()
        }
    }

    private func activateControl() {
        guard shouldActivateControl else {
            if Self.verbose {
                Self.log.debug("\(Self.tag) Skipping audiobook playback controls: current scene is not Books")
            }
            return
        }

        if Self.verbose {
            Self.log.debug("\(Self.tag)👀 View appeared, initializing audiobook playback controls")
        }

        guard playMan != nil else { return }
    }

    private func deactivateControl() {
        controlGeneration = BookControlPlaybackRequestPolicy.generationAfterDeactivation(controlGeneration)
        BookControlChapterCache.removeAll()

        _ = playMan
    }

    func handlePlaybackEvent(_ event: PlaybackProvidingEvent) {
        switch event {
        case .previousRequested(let asset):
            handlePreviousRequested(asset)
        case .nextRequested(let asset):
            handleNextRequested(asset)
        default:
            break
        }
    }

    // MARK: - Navigation

    func handlePreviousRequested(_ asset: URL) {
        guard shouldActivateControl, let playMan else { return }

        if Self.verbose {
            Self.log.debug("\(Self.tag)⏮️ Previous chapter requested")
        }

        let bookDisk = BookPlugin.getBookDisk()
        guard BookControlPlaybackRequestPolicy.shouldNavigateBookAsset(asset, bookDisk: bookDisk) else {
            return
        }

        let root = BookControlBookRootResolver.bookRoot(containing: asset, bookDisk: bookDisk)
        let playMode = playMan.playMode
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
                    currentAsset: playMan.currentAsset,
                    isSceneActive: shouldActivateControl,
                    currentGeneration: controlGeneration,
                    requestGeneration: generation
                ) else { return }
                await playMan.play(prev, reason: "handlePreviousRequested")
                if Self.verbose {
                    Self.log.debug("\(Self.tag)✅ Playing previous chapter: \(prev.lastPathComponent)")
                }
            } else if Self.verbose {
                Self.log.debug("\(Self.tag)⚠️ No previous chapter")
            }
        }
    }

    func handleNextRequested(_ asset: URL) {
        guard shouldActivateControl, let playMan else { return }

        if Self.verbose {
            Self.log.debug("\(Self.tag)⏭️ Next chapter requested")
        }

        let bookDisk = BookPlugin.getBookDisk()
        guard BookControlPlaybackRequestPolicy.shouldNavigateBookAsset(asset, bookDisk: bookDisk) else {
            return
        }

        let root = BookControlBookRootResolver.bookRoot(containing: asset, bookDisk: bookDisk)
        let playMode = playMan.playMode
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
                    currentAsset: playMan.currentAsset,
                    isSceneActive: shouldActivateControl,
                    currentGeneration: controlGeneration,
                    requestGeneration: generation
                ) else { return }
                await playMan.play(next, reason: "handleNextRequested")
                if Self.verbose {
                    Self.log.debug("\(Self.tag)✅ Playing next chapter: \(next.lastPathComponent)")
                }
            } else if Self.verbose {
                Self.log.debug("\(Self.tag)⚠️ No next chapter")
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

    // MARK: - DB & storage events

    func handleBookDBDeleted(deletedURLs: [URL]) {
        guard let playMan else { return }

        if BookControlPlaybackRequestPolicy.shouldInvalidateChapterCacheAfterDeletion(deletedURLs: deletedURLs) {
            BookControlChapterCache.removeAll()
        }

        guard BookControlPlaybackRequestPolicy.currentAssetAffectedByDeletion(
            currentAsset: playMan.asset,
            deletedURLs: deletedURLs
        ) else { return }

        let generation = controlGeneration
        Task {
            guard BookControlPlaybackRequestPolicy.shouldApplyDeletionReset(
                currentAsset: playMan.asset,
                deletedURLs: deletedURLs,
                currentGeneration: controlGeneration,
                requestGeneration: generation
            ) else { return }
            await playMan.reset(reason: "BookControlViewModel.deletedCurrentAsset")
        }
    }

    func handleBookDBRefreshed() {
        guard BookControlPlaybackRequestPolicy.shouldInvalidateChapterCacheAfterLibraryRefresh() else {
            return
        }
        BookControlChapterCache.removeAll()
    }

    func handleStorageLocationDidReset() {
        guard let playMan else { return }
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
            ) else { return }

            await playMan.reset(reason: "BookControlViewModel.storageLocationDidReset")
        }
    }
}
