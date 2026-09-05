import AVFoundation
import Foundation
import MagicPlayMan
import OSLog
import PluginAudio
import PluginAudioLike
import ProviderPlayback
import ProviderScene
import SwiftUI
import UniformTypeIdentifiers
import WidgetKit

/// 音频播放进度的集中状态容器（迁移 Phase 5）。
///
/// 持有恢复代际与场景激活状态，统一处理进度恢复、URL变化持久化、
/// 暂停保存、删除清理、Widget 同步与存储重置；取代原
/// `AudioProgressRootView` 内的全部 `@State` 与事件 handler。
/// 由 `AudioProgressPlugin` 入口持有。
@MainActor
final class AudioProgressViewModel: ObservableObject {
    private static let verbose = false
    private static let log = Logger(subsystem: "com.yueyi.cisum", category: "AudioProgress")
    private static let tag = "💾"

    private weak var playMan: MagicPlayMan?
    private var restoreGeneration = 0
    private var currentScene: AppScene?
    private let audioScene: AppScene
    private let audioRepo: @MainActor () async -> AudioRepo?
    private let saveWidgetData: @Sendable (String, String, Bool, Data?) -> Void

    init(
        audioScene: AppScene,
        audioRepo: @escaping @MainActor () async -> AudioRepo?,
        saveWidgetData: @escaping @Sendable (String, String, Bool, Data?) -> Void
    ) {
        self.audioScene = audioScene
        self.audioRepo = audioRepo
        self.saveWidgetData = saveWidgetData
    }

    func bind(playMan: MagicPlayMan?) {
        self.playMan = playMan
    }

    var shouldActivateProgress: Bool {
        currentScene == audioScene
    }

    // MARK: - Scene activation

    func handleSceneChange(from oldScene: AppScene?, to newScene: AppScene?) {
        currentScene = newScene

        if newScene != audioScene {
            restoreGeneration += 1
        }

        if AudioProgressPersistencePolicy.shouldPersistWhenSceneChanges(
            from: oldScene?.rawValue,
            to: newScene?.rawValue,
            audioSceneName: audioScene.rawValue
        ) {
            persistCurrentTime(reason: "handleCurrentSceneChanged")
        }

        restorePlayingIfNeeded(for: newScene)
    }

    func handleOnAppear() {
        restorePlayingIfNeeded(for: currentScene)
    }

    func handleOnDisappear() {
        restoreGeneration += 1
        guard shouldActivateProgress else { return }
        persistCurrentTime(reason: "handleOnDisappear")
    }

    func handlePlaybackEvent(_ event: PlaybackProvidingEvent) {
        switch event {
        case .stateChanged(let state):
            handlePlayManStateChanged(state == .playing)
        case .assetChanged(let url):
            handlePlayManAssetChanged(url)
        default:
            break
        }
    }

    private func restorePlayingIfNeeded(for sceneValue: AppScene?) {
        guard sceneValue == audioScene else { return }
        restorePlaying()
    }

    // MARK: - Restore

    private func restorePlaying() {
        guard let playMan else { return }
        var assetTarget: URL?
        var timeTarget: TimeInterval = 0
        var liked = false
        let startingAsset = playMan.currentAsset
        restoreGeneration += 1
        let generation = restoreGeneration

        Task { @MainActor in
            guard isCurrentRestoreRequest(generation) else { return }

            guard let repo = await audioRepo() else {
                if Self.verbose {
                    Self.log.error("\(Self.tag)❌ Failed to get AudioRepo")
                }
                return
            }

            if let url = AudioStateRepo.getCurrent() {
                let isPlayable = await repo.find(url) != nil && isPlayableAudioURL(url)

                if isPlayable {
                    assetTarget = url
                    liked = await AudioLikeRepo.shared.isLiked(url: url)

                    if let time = AudioStateRepo.getCurrentTime() {
                        timeTarget = time
                    }

                    if Self.verbose {
                        Self.log.debug("\(Self.tag)✅ Restored playback: \(url.lastPathComponent) @ \(timeTarget)s")
                    }
                } else {
                    if AudioProgressPersistencePolicy.shouldClearRestoredCurrentURL(storedURL: url, isPlayable: isPlayable) {
                        AudioStateRepo.storeCurrent(nil)
                    }
                    if AudioProgressPersistencePolicy.shouldClearRestoredCurrentTime(storedURL: url, isPlayable: isPlayable) {
                        AudioStateRepo.storeCurrentTime(0)
                    }

                    if Self.verbose {
                        Self.log.debug("\(Self.tag)⚠️ Last played file no longer exists: \(url.lastPathComponent)")
                    }

                    if let firstUrl = await firstPlayableAudio(in: repo) {
                        assetTarget = firstUrl
                        liked = await AudioLikeRepo.shared.isLiked(url: firstUrl)

                        if Self.verbose {
                            Self.log.debug("\(Self.tag)✅ Playing first track: \(firstUrl.lastPathComponent)")
                        }
                    }
                }
            } else {
                if Self.verbose {
                    Self.log.debug("\(Self.tag)⚠️ No previous playback record")
                }
            }

            if let asset = assetTarget {
                guard AudioProgressPersistencePolicy.shouldApplyRestoreResult(
                    startingAsset: startingAsset,
                    currentAsset: playMan.currentAsset
                ) else { return }

                let reason = "AudioProgressViewModel.restorePlaybackData"
                if AudioProgressPersistencePolicy.shouldPlayRestoredAsset(
                    restoredAsset: asset,
                    currentAsset: playMan.currentAsset
                ) {
                    guard isCurrentRestoreRequest(generation) else { return }
                    await playMan.play(asset, autoPlay: false, startTime: timeTarget, reason: reason)
                }
                guard isCurrentRestoreRequest(generation) else { return }
                playMan.setLike(liked, reason: reason)
            } else {
                if Self.verbose {
                    Self.log.debug("\(Self.tag)⚠️ No playback data to restore")
                }
            }
        }
    }

    private func isCurrentRestoreRequest(_ generation: Int) -> Bool {
        AudioProgressPersistencePolicy.shouldApplyRestoreRequest(
            currentGeneration: restoreGeneration,
            requestGeneration: generation,
            isSceneActive: shouldActivateProgress
        )
    }

    private func firstPlayableAudio(in repo: AudioRepo) async -> URL? {
        let urls = await repo.getAll(reason: "AudioProgressViewModel.firstPlayableAudio")
        return urls.first(where: isPlayableAudioURL)
    }

    private func isPlayableAudioURL(_ url: URL) -> Bool {
        FileManager.default.fileExists(atPath: url.path)
            && !url.isFolder
            && AudioPlugin.supportedExtensions.contains(url.pathExtension.lowercased())
    }

    // MARK: - Playback events

    func handlePlayManStateChanged(_ isPlaying: Bool) {
        guard shouldActivateProgress, let playMan else { return }

        syncToWidget(url: playMan.currentAsset, isPlaying: isPlaying)

        if playMan.state == .paused {
            persistCurrentTime(reason: "handlePlayManStateChanged")
        }
    }

    func handlePlayManAssetChanged(_ url: URL?) {
        guard shouldActivateProgress, let playMan else { return }

        syncToWidget(url: url, isPlaying: playMan.state == .playing)
        let generation = restoreGeneration

        Task {
            guard AudioProgressPersistencePolicy.shouldApplyCurrentURLChange(
                requestedURL: url,
                currentAsset: playMan.currentAsset,
                currentGeneration: restoreGeneration,
                requestGeneration: generation,
                isSceneActive: shouldActivateProgress
            ) else { return }

            let storedURL = AudioStateRepo.getCurrent()
            let urlToStore = AudioProgressPersistencePolicy.currentURLToStore(
                url,
                storedURL: storedURL,
                supportedExtensions: AudioPlugin.supportedExtensions
            )
            AudioStateRepo.storeCurrent(urlToStore)
            if AudioProgressPersistencePolicy.shouldResetGlobalTimeWhenCurrentURLChanges(from: storedURL, to: urlToStore) {
                AudioStateRepo.storeCurrentTime(0)
            }
        }
    }

    func handleDBDeleted(deletedURLs: [URL]) {
        guard AudioProgressPersistencePolicy.shouldClearStoredCurrentAfterDelete(
            storedURL: AudioStateRepo.getCurrent(),
            deletedURLs: deletedURLs
        ) else { return }

        AudioStateRepo.storeCurrent(nil)
        AudioStateRepo.storeCurrentTime(0)
    }

    func handleStorageLocationDidReset() {
        guard shouldActivateProgress else { return }

        if Self.verbose {
            Self.log.debug("\(Self.tag)🛑 Storage location reset; recording playback progress")
        }

        persistCurrentTime(reason: "handleStorageLocationDidReset")
    }

    // MARK: - Widget & persistence

    private func syncToWidget(url: URL?, isPlaying: Bool) {
        guard let playMan else { return }
        guard let url = url else {
            guard AudioProgressPersistencePolicy.shouldApplyWidgetClearResult(currentAsset: playMan.currentAsset) else {
                return
            }

            saveWidgetData("Not Playing", "Cisum", false, nil)
            return
        }

        let title = url.deletingPathExtension().lastPathComponent
        let artist = "Cisum"

        Task {
            var coverArt: Data? = nil
            let asset = AVAsset(url: url)
            do {
                let metadata = try await asset.load(.commonMetadata)
                if let artworkItem = metadata.first(where: { $0.commonKey == .commonKeyArtwork }),
                   let data = try await artworkItem.load(.value) as? Data {
                    coverArt = data
                }
            } catch {
                if Self.verbose {
                    Self.log.error("\(Self.tag) Failed to load artwork: \(error.localizedDescription)")
                }
            }

            guard AudioProgressPersistencePolicy.shouldApplyWidgetMetadataResult(
                requestedAsset: url,
                currentAsset: playMan.currentAsset
            ) else { return }

            saveWidgetData(title, artist, playMan.state == .playing, coverArt)
        }
    }

    private func persistCurrentTime(reason: String) {
        guard let playMan else { return }
        AudioStateRepo.storeCurrentTime(playMan.currentTime)

        if Self.verbose {
            Self.log.debug("\(Self.tag)💾 (\(reason)) Saved playback progress: \(playMan.currentTime)s")
        }
    }
}
