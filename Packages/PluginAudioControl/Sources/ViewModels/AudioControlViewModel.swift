import Combine
import Foundation
import MagicAlert
import MagicKit
import MagicPlayMan
import OSLog
import ProviderScene

/// 音频播放控制的集中状态容器（迁移 Phase 5）。
///
/// 持有播放控制订阅、代际保护与场景激活状态，统一处理上一首/下一首、
/// 删除恢复、存储位置重置；取代原 `AudioControlRootView` 内的全部
/// `@State` 与事件 handler。由 `AudioControlPlugin` 入口持有。
///
/// ViewModel 不直接持有 Kernel 或具体 Provider：外部播放状态由
/// `AudioControlObserver` 通过 `apply...` 方法回写，外部播放操作通过
/// `AudioControlPlaybackCapability` 执行。
@MainActor
final class AudioControlViewModel: ObservableObject, SuperLog {
    private static let verbose = true
    private static let log = Logger(subsystem: "com.yueyi.cisum", category: "AudioControl")

    private let playbackCapability: (any AudioControlPlaybackCapability)?
    private var controlGeneration = 0
    private var currentScene: AppScene?
    private let targetScene: AppScene

    private let nextAsset: AudioControlAdjacentAssetProvider
    private let previousAsset: AudioControlAdjacentAssetProvider
    private let firstAsset: AudioControlFirstAssetProvider
    private let lastAsset: AudioControlLastAssetProvider

    init(
        targetScene: AppScene,
        playbackCapability: (any AudioControlPlaybackCapability)?,
        nextAsset: @escaping AudioControlAdjacentAssetProvider,
        previousAsset: @escaping AudioControlAdjacentAssetProvider,
        firstAsset: @escaping AudioControlFirstAssetProvider,
        lastAsset: @escaping AudioControlLastAssetProvider
    ) {
        self.targetScene = targetScene
        self.playbackCapability = playbackCapability
        self.nextAsset = nextAsset
        self.previousAsset = previousAsset
        self.firstAsset = firstAsset
        self.lastAsset = lastAsset
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
                Self.log.debug("Skip playback control because current scene is not audio")
            }
            return
        }

        guard playbackCapability != nil else { return }
    }

    private func deactivateControl() {
        controlGeneration = AudioControlPlaybackRequestPolicy.generationAfterDeactivation(controlGeneration)
    }

    // MARK: - Navigation

    func handlePreviousRequested(_ asset: URL, ignoreSceneCheck: Bool = false) {
        guard shouldActivateControl || ignoreSceneCheck else { return }
        guard let playback = playbackCapability else { return }

        let generation = controlGeneration
        Task { @MainActor in
            do {
                if let previous = try await previousAsset(asset, false) {
                    guard AudioControlPlaybackRequestPolicy.shouldApplyNavigationResult(
                        requestedAsset: asset,
                        currentAsset: playback.currentURL,
                        isSceneActive: shouldActivateControl || ignoreSceneCheck,
                        currentGeneration: controlGeneration,
                        requestGeneration: generation
                    ) else { return }
                    await playback.play(previous)
                    return
                }

                if playback.playMode == .repeatAll, let last = try await lastAsset() {
                    guard AudioControlPlaybackRequestPolicy.shouldApplyNavigationResult(
                        requestedAsset: asset,
                        currentAsset: playback.currentURL,
                        isSceneActive: shouldActivateControl || ignoreSceneCheck,
                        currentGeneration: controlGeneration,
                        requestGeneration: generation
                    ) else { return }
                    await playback.play(last)
                } else if playback.playMode == .repeatAll {
                    guard AudioControlPlaybackRequestPolicy.shouldApplyNavigationResult(
                        requestedAsset: asset,
                        currentAsset: playback.currentURL,
                        isSceneActive: shouldActivateControl || ignoreSceneCheck,
                        currentGeneration: controlGeneration,
                        requestGeneration: generation
                    ) else { return }
                    await playback.reset()
                    alert_info(String(localized: "No files in library", bundle: .module))
                }
            } catch {
                guard AudioControlPlaybackRequestPolicy.shouldReportNavigationFailure(
                    requestedAsset: asset,
                    currentAsset: playback.currentURL,
                    isSceneActive: shouldActivateControl || ignoreSceneCheck,
                    currentGeneration: controlGeneration,
                    requestGeneration: generation
                ) else { return }
                if Self.verbose {
                    Self.log.error("Failed to get previous asset: \(error.localizedDescription)")
                }
                alert_error(String(localized: "Cannot play previous: \(error.localizedDescription)", bundle: .module))
            }
        }
    }

    func handleNextRequested(_ asset: URL, ignoreSceneCheck: Bool = false) {
        guard shouldActivateControl || ignoreSceneCheck else { return }
        guard let playback = playbackCapability else { return }

        let generation = controlGeneration
        Task { @MainActor in
            do {
                if let next = try await nextAsset(asset, Self.verbose) {
                    guard AudioControlPlaybackRequestPolicy.shouldApplyNavigationResult(
                        requestedAsset: asset,
                        currentAsset: playback.currentURL,
                        isSceneActive: shouldActivateControl || ignoreSceneCheck,
                        currentGeneration: controlGeneration,
                        requestGeneration: generation
                    ) else { return }
                    await playback.play(next)
                    return
                }

                guard playback.playMode == .repeatAll else { return }

                if let first = try await firstAsset() {
                    guard AudioControlPlaybackRequestPolicy.shouldApplyNavigationResult(
                        requestedAsset: asset,
                        currentAsset: playback.currentURL,
                        isSceneActive: shouldActivateControl || ignoreSceneCheck,
                        currentGeneration: controlGeneration,
                        requestGeneration: generation
                    ) else { return }
                    alert_info(String(localized: "Reached the last track, playing the first", bundle: .module))
                    await playback.play(first)
                } else {
                    guard AudioControlPlaybackRequestPolicy.shouldApplyNavigationResult(
                        requestedAsset: asset,
                        currentAsset: playback.currentURL,
                        isSceneActive: shouldActivateControl || ignoreSceneCheck,
                        currentGeneration: controlGeneration,
                        requestGeneration: generation
                    ) else { return }
                    await playback.reset()
                    alert_info(String(localized: "No files in library", bundle: .module))
                }
            } catch {
                guard AudioControlPlaybackRequestPolicy.shouldReportNavigationFailure(
                    requestedAsset: asset,
                    currentAsset: playback.currentURL,
                    isSceneActive: shouldActivateControl || ignoreSceneCheck,
                    currentGeneration: controlGeneration,
                    requestGeneration: generation
                ) else { return }
                if Self.verbose {
                    Self.log.error("Failed to get next asset: \(error.localizedDescription)")
                }
                alert_error(String(localized: "Cannot play next: \(error.localizedDescription)", bundle: .module))
            }
        }
    }

    // MARK: - Storage & deletion events

    func handleStorageLocationDidReset() {
        guard AudioControlPlaybackRequestPolicy.shouldResetForStorageLocationChange(isSceneActive: shouldActivateControl) else {
            return
        }
        guard let playback = playbackCapability else { return }

        let generation = controlGeneration
        Task { @MainActor in
            guard AudioControlPlaybackRequestPolicy.shouldApplyStorageReset(
                currentGeneration: controlGeneration,
                requestGeneration: generation,
                isSceneActive: shouldActivateControl
            ) else { return }

            await playback.reset()
        }
    }

    func handleDBDeleted(urlsToDelete: [URL]) {
        guard let playback = playbackCapability else { return }
        guard AudioControlPlaybackRequestPolicy.currentAssetAffectedByDeletion(
            currentAsset: playback.currentURL,
            deletedURLs: urlsToDelete
        ) else { return }

        let generation = controlGeneration
        Task { @MainActor in
            guard AudioControlPlaybackRequestPolicy.currentAssetAffectedByDeletion(
                currentAsset: playback.currentURL,
                deletedURLs: urlsToDelete
            ) else { return }

            guard shouldActivateControl else {
                guard AudioControlPlaybackRequestPolicy.shouldApplyDeletionRecovery(
                    currentAsset: playback.currentURL,
                    deletedURLs: urlsToDelete,
                    currentGeneration: controlGeneration,
                    requestGeneration: generation
                ) else { return }
                await playback.reset()
                return
            }

            do {
                if let first = try await firstAsset() {
                    guard AudioControlPlaybackRequestPolicy.shouldApplyDeletionRecovery(
                        currentAsset: playback.currentURL,
                        deletedURLs: urlsToDelete,
                        currentGeneration: controlGeneration,
                        requestGeneration: generation
                    ) else { return }
                    alert_warning(String(localized: "Current file was deleted, playing the first", bundle: .module))
                    await playback.play(first)
                } else {
                    guard AudioControlPlaybackRequestPolicy.shouldApplyDeletionRecovery(
                        currentAsset: playback.currentURL,
                        deletedURLs: urlsToDelete,
                        currentGeneration: controlGeneration,
                        requestGeneration: generation
                    ) else { return }
                    await playback.reset()
                    alert_info(String(localized: "No files in library", bundle: .module))
                }
            } catch {
                guard AudioControlPlaybackRequestPolicy.shouldApplyDeletionRecovery(
                    currentAsset: playback.currentURL,
                    deletedURLs: urlsToDelete,
                    currentGeneration: controlGeneration,
                    requestGeneration: generation
                ) else { return }
                await playback.reset()
                alert_error(String(localized: "Cannot play next: \(error.localizedDescription)", bundle: .module))
            }
        }
    }
}
