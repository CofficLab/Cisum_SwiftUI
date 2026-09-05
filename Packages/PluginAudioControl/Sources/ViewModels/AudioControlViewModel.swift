import Combine
import Foundation
import MagicAlert
import MagicPlayMan
import OSLog
import ProviderPlayback
import ProviderScene

/// 音频播放控制的集中状态容器（迁移 Phase 5）。
///
/// 持有播放控制订阅、代际保护与场景激活状态，统一处理上一首/下一首、
/// 删除恢复、存储位置重置；取代原 `AudioControlRootView` 内的全部
/// `@State` 与事件 handler。由 `AudioControlPlugin` 入口持有。
@MainActor
final class AudioControlViewModel: ObservableObject {
    private static let verbose = true
    private static let log = Logger(subsystem: "com.yueyi.cisum", category: "AudioControl")
    private static let author = "AudioControlViewModel"

    private weak var playMan: MagicPlayMan?
    private var controlGeneration = 0
    private var currentScene: AppScene?
    private let targetScene: AppScene

    private let nextAsset: AudioControlAdjacentAssetProvider
    private let previousAsset: AudioControlAdjacentAssetProvider
    private let firstAsset: AudioControlFirstAssetProvider
    private let lastAsset: AudioControlLastAssetProvider

    init(
        targetScene: AppScene,
        nextAsset: @escaping AudioControlAdjacentAssetProvider,
        previousAsset: @escaping AudioControlAdjacentAssetProvider,
        firstAsset: @escaping AudioControlFirstAssetProvider,
        lastAsset: @escaping AudioControlLastAssetProvider
    ) {
        self.targetScene = targetScene
        self.nextAsset = nextAsset
        self.previousAsset = previousAsset
        self.firstAsset = firstAsset
        self.lastAsset = lastAsset
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
                Self.log.debug("Skip playback control because current scene is not audio")
            }
            return
        }

        guard playMan != nil else { return }
    }

    private func deactivateControl() {
        controlGeneration = AudioControlPlaybackRequestPolicy.generationAfterDeactivation(controlGeneration)

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

    func handlePreviousRequested(_ asset: URL, ignoreSceneCheck: Bool = false) {
        guard shouldActivateControl || ignoreSceneCheck else { return }
        guard let playMan else { return }

        let generation = controlGeneration
        Task { @MainActor in
            do {
                if let previous = try await previousAsset(asset, false) {
                    guard AudioControlPlaybackRequestPolicy.shouldApplyNavigationResult(
                        requestedAsset: asset,
                        currentAsset: playMan.currentAsset,
                        isSceneActive: shouldActivateControl || ignoreSceneCheck,
                        currentGeneration: controlGeneration,
                        requestGeneration: generation
                    ) else { return }
                    await playMan.play(previous, autoPlay: true, reason: "AudioControlViewModel")
                    return
                }

                if playMan.playMode == .repeatAll, let last = try await lastAsset() {
                    guard AudioControlPlaybackRequestPolicy.shouldApplyNavigationResult(
                        requestedAsset: asset,
                        currentAsset: playMan.currentAsset,
                        isSceneActive: shouldActivateControl || ignoreSceneCheck,
                        currentGeneration: controlGeneration,
                        requestGeneration: generation
                    ) else { return }
                    await playMan.play(last, autoPlay: true, reason: "AudioControlViewModel.repeatAllPrevious")
                } else if playMan.playMode == .repeatAll {
                    guard AudioControlPlaybackRequestPolicy.shouldApplyNavigationResult(
                        requestedAsset: asset,
                        currentAsset: playMan.currentAsset,
                        isSceneActive: shouldActivateControl || ignoreSceneCheck,
                        currentGeneration: controlGeneration,
                        requestGeneration: generation
                    ) else { return }
                    await playMan.reset(reason: "AudioControlViewModel.emptyLibrary")
                    alert_info(String(localized: "No files in library", bundle: .module))
                }
            } catch {
                guard AudioControlPlaybackRequestPolicy.shouldReportNavigationFailure(
                    requestedAsset: asset,
                    currentAsset: playMan.currentAsset,
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
        guard let playMan else { return }

        let generation = controlGeneration
        Task { @MainActor in
            do {
                if let next = try await nextAsset(asset, Self.verbose) {
                    guard AudioControlPlaybackRequestPolicy.shouldApplyNavigationResult(
                        requestedAsset: asset,
                        currentAsset: playMan.currentAsset,
                        isSceneActive: shouldActivateControl || ignoreSceneCheck,
                        currentGeneration: controlGeneration,
                        requestGeneration: generation
                    ) else { return }
                    await playMan.play(next, autoPlay: true, reason: "AudioControlViewModel.handleNextRequested")
                    return
                }

                guard playMan.playMode == .repeatAll else { return }

                if let first = try await firstAsset() {
                    guard AudioControlPlaybackRequestPolicy.shouldApplyNavigationResult(
                        requestedAsset: asset,
                        currentAsset: playMan.currentAsset,
                        isSceneActive: shouldActivateControl || ignoreSceneCheck,
                        currentGeneration: controlGeneration,
                        requestGeneration: generation
                    ) else { return }
                    alert_info(String(localized: "Reached the last track, playing the first", bundle: .module))
                    await playMan.play(first, autoPlay: true, reason: "AudioControlViewModel.loop")
                } else {
                    guard AudioControlPlaybackRequestPolicy.shouldApplyNavigationResult(
                        requestedAsset: asset,
                        currentAsset: playMan.currentAsset,
                        isSceneActive: shouldActivateControl || ignoreSceneCheck,
                        currentGeneration: controlGeneration,
                        requestGeneration: generation
                    ) else { return }
                    await playMan.reset(reason: "AudioControlViewModel.emptyLibrary")
                    alert_info(String(localized: "No files in library", bundle: .module))
                }
            } catch {
                guard AudioControlPlaybackRequestPolicy.shouldReportNavigationFailure(
                    requestedAsset: asset,
                    currentAsset: playMan.currentAsset,
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
        guard let playMan else { return }

        let generation = controlGeneration
        Task { @MainActor in
            guard AudioControlPlaybackRequestPolicy.shouldApplyStorageReset(
                currentGeneration: controlGeneration,
                requestGeneration: generation,
                isSceneActive: shouldActivateControl
            ) else { return }

            await playMan.reset(reason: "AudioControlViewModel.storageLocationDidReset")
        }
    }

    func handleDBDeleted(urlsToDelete: [URL]) {
        guard let playMan else { return }
        guard AudioControlPlaybackRequestPolicy.currentAssetAffectedByDeletion(
            currentAsset: playMan.asset,
            deletedURLs: urlsToDelete
        ) else { return }

        let generation = controlGeneration
        Task { @MainActor in
            guard AudioControlPlaybackRequestPolicy.currentAssetAffectedByDeletion(
                currentAsset: playMan.asset,
                deletedURLs: urlsToDelete
            ) else { return }

            guard shouldActivateControl else {
                guard AudioControlPlaybackRequestPolicy.shouldApplyDeletionRecovery(
                    currentAsset: playMan.asset,
                    deletedURLs: urlsToDelete,
                    currentGeneration: controlGeneration,
                    requestGeneration: generation
                ) else { return }
                await playMan.reset(reason: "AudioControlViewModel.deletedCurrentAsset")
                return
            }

            do {
                if let first = try await firstAsset() {
                    guard AudioControlPlaybackRequestPolicy.shouldApplyDeletionRecovery(
                        currentAsset: playMan.asset,
                        deletedURLs: urlsToDelete,
                        currentGeneration: controlGeneration,
                        requestGeneration: generation
                    ) else { return }
                    alert_warning(String(localized: "Current file was deleted, playing the first", bundle: .module))
                    await playMan.play(first, autoPlay: true, reason: "AudioControlViewModel")
                } else {
                    guard AudioControlPlaybackRequestPolicy.shouldApplyDeletionRecovery(
                        currentAsset: playMan.asset,
                        deletedURLs: urlsToDelete,
                        currentGeneration: controlGeneration,
                        requestGeneration: generation
                    ) else { return }
                    await playMan.reset(reason: "AudioControlViewModel.emptyLibrary")
                    alert_info(String(localized: "No files in library", bundle: .module))
                }
            } catch {
                guard AudioControlPlaybackRequestPolicy.shouldApplyDeletionRecovery(
                    currentAsset: playMan.asset,
                    deletedURLs: urlsToDelete,
                    currentGeneration: controlGeneration,
                    requestGeneration: generation
                ) else { return }
                await playMan.reset(reason: "AudioControlViewModel.getFirstFailed")
                alert_error(String(localized: "Cannot play next: \(error.localizedDescription)", bundle: .module))
            }
        }
    }
}
