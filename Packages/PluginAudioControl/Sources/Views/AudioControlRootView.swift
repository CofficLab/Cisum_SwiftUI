import Foundation
import CisumUIComponents
import MagicPlayMan
import OSLog
import ProviderScene
import SwiftUI

public typealias AudioControlAdjacentAssetProvider = @MainActor (_ current: URL?, _ verbose: Bool) async throws -> URL?
public typealias AudioControlFirstAssetProvider = @MainActor () async throws -> URL?
public typealias AudioControlLastAssetProvider = @MainActor () async throws -> URL?

private enum AudioControlRuntime {
    static let verbose = true
    static let log = Logger(subsystem: "com.yueyi.cisum", category: "AudioControl")
    static let author = "AudioControlRootView"
}

enum AudioControlPlaybackRequestPolicy {
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

    static func shouldReportNavigationFailure(
        requestedAsset: URL,
        currentAsset: URL?,
        isSceneActive: Bool,
        currentGeneration: Int = 0,
        requestGeneration: Int = 0
    ) -> Bool {
        shouldApplyNavigationResult(
            requestedAsset: requestedAsset,
            currentAsset: currentAsset,
            isSceneActive: isSceneActive,
            currentGeneration: currentGeneration,
            requestGeneration: requestGeneration
        )
    }

    static func currentAssetAffectedByDeletion(currentAsset: URL?, deletedURLs: [URL]) -> Bool {
        guard let currentAsset else { return false }
        return deletedURLs.contains { deletedURL in
            representsSameFile(currentAsset, deletedURL)
        }
    }

    static func shouldApplyDeletionRecovery(
        currentAsset: URL?,
        deletedURLs: [URL],
        currentGeneration: Int = 0,
        requestGeneration: Int = 0
    ) -> Bool {
        currentGeneration == requestGeneration
            && currentAssetAffectedByDeletion(currentAsset: currentAsset, deletedURLs: deletedURLs)
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
        switch (lhs, rhs) {
        case (.none, .none):
            return true
        case let (.some(lhs), .some(rhs)):
            return lhs.isSameFileLocation(as: rhs)
        default:
            return false
        }
    }

    private static func representsSameFile(_ lhs: URL, _ rhs: URL) -> Bool {
        lhs.isSameFileLocation(as: rhs)
    }
}

public struct AudioControlRootView<Content>: View where Content: View {
    @EnvironmentObject private var man: MagicPlayMan
    @State private var playbackSubscriptionID: UUID?
    @State private var controlGeneration = 0

    private let content: Content
    private let targetSceneName: String
    private let scene: (any SceneProviding)?
    private let nextAsset: AudioControlAdjacentAssetProvider
    private let previousAsset: AudioControlAdjacentAssetProvider
    private let firstAsset: AudioControlFirstAssetProvider
    private let lastAsset: AudioControlLastAssetProvider

    public init(
        targetSceneName: String,
        scene: (any SceneProviding)?,
        nextAsset: @escaping AudioControlAdjacentAssetProvider,
        previousAsset: @escaping AudioControlAdjacentAssetProvider,
        firstAsset: @escaping AudioControlFirstAssetProvider,
        lastAsset: @escaping AudioControlLastAssetProvider,
        @ViewBuilder content: () -> Content
    ) {
        self.targetSceneName = targetSceneName
        self.scene = scene
        self.nextAsset = nextAsset
        self.previousAsset = previousAsset
        self.firstAsset = firstAsset
        self.lastAsset = lastAsset
        self.content = content()
    }

    public var body: some View {
        content
            .onAppear(perform: handleOnAppear)
            .onDisappear(perform: handleOnDisappear)
            .onChange(of: scene?.currentSceneName) { _, newSceneName in
                handleCurrentSceneChanged(newSceneName)
            }
            .onReceive(NotificationCenter.default.publisher(for: .audioControlDBDeleted), perform: handleDBDeleted)
            .onReceive(NotificationCenter.default.publisher(for: .audioControlStorageLocationDidReset)) { _ in
                handleStorageLocationDidReset()
            }
    }

    private var shouldActivateControl: Bool {
        scene?.currentSceneName == targetSceneName
    }
}

private extension AudioControlRootView {
    func handleOnAppear() {
        updateControlActivation(for: scene?.currentSceneName)
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
            if AudioControlRuntime.verbose {
                AudioControlRuntime.log.debug("Skip playback control because current scene is not audio")
            }
            return
        }

        guard playbackSubscriptionID == nil else { return }

        playbackSubscriptionID = man.subscribe(
            name: AudioControlRuntime.author,
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
        controlGeneration = AudioControlPlaybackRequestPolicy.generationAfterDeactivation(controlGeneration)

        guard let playbackSubscriptionID else { return }

        man.unsubscribe(playbackSubscriptionID)
        self.playbackSubscriptionID = nil
    }

    func handlePreviousRequested(_ asset: URL, ignoreSceneCheck: Bool = false) {
        guard shouldActivateControl || ignoreSceneCheck else { return }

        let generation = controlGeneration
        Task { @MainActor in
            do {
                if let previous = try await previousAsset(asset, false) {
                    guard AudioControlPlaybackRequestPolicy.shouldApplyNavigationResult(
                        requestedAsset: asset,
                        currentAsset: man.currentAsset,
                        isSceneActive: shouldActivateControl || ignoreSceneCheck,
                        currentGeneration: controlGeneration,
                        requestGeneration: generation
                    ) else {
                        return
                    }
                    await man.play(previous, autoPlay: true, reason: "AudioControlRootView")
                    return
                }

                if man.playMode == .repeatAll, let last = try await lastAsset() {
                    guard AudioControlPlaybackRequestPolicy.shouldApplyNavigationResult(
                        requestedAsset: asset,
                        currentAsset: man.currentAsset,
                        isSceneActive: shouldActivateControl || ignoreSceneCheck,
                        currentGeneration: controlGeneration,
                        requestGeneration: generation
                    ) else {
                        return
                    }
                    await man.play(last, autoPlay: true, reason: "AudioControlRootView.repeatAllPrevious")
                } else if man.playMode == .repeatAll {
                    guard AudioControlPlaybackRequestPolicy.shouldApplyNavigationResult(
                        requestedAsset: asset,
                        currentAsset: man.currentAsset,
                        isSceneActive: shouldActivateControl || ignoreSceneCheck,
                        currentGeneration: controlGeneration,
                        requestGeneration: generation
                    ) else {
                        return
                    }
                    await man.reset(reason: "AudioControlRootView.emptyLibrary")
                    alert_info(String(localized: "No files in library", bundle: .module))
                }
            } catch {
                guard AudioControlPlaybackRequestPolicy.shouldReportNavigationFailure(
                    requestedAsset: asset,
                    currentAsset: man.currentAsset,
                    isSceneActive: shouldActivateControl || ignoreSceneCheck,
                    currentGeneration: controlGeneration,
                    requestGeneration: generation
                ) else {
                    return
                }
                if AudioControlRuntime.verbose {
                    AudioControlRuntime.log.error("Failed to get previous asset: \(error.localizedDescription)")
                }
                alert_error(String(localized: "Cannot play previous: \(error.localizedDescription)", bundle: .module))
            }
        }
    }

    func handleNextRequested(_ asset: URL, ignoreSceneCheck: Bool = false) {
        guard shouldActivateControl || ignoreSceneCheck else { return }

        let generation = controlGeneration
        Task { @MainActor in
            do {
                if let next = try await nextAsset(asset, AudioControlRuntime.verbose) {
                    guard AudioControlPlaybackRequestPolicy.shouldApplyNavigationResult(
                        requestedAsset: asset,
                        currentAsset: man.currentAsset,
                        isSceneActive: shouldActivateControl || ignoreSceneCheck,
                        currentGeneration: controlGeneration,
                        requestGeneration: generation
                    ) else {
                        return
                    }
                    await man.play(next, autoPlay: true, reason: "AudioControlRootView.handleNextRequested")
                    return
                }

                guard man.playMode == .repeatAll else {
                    return
                }

                if let first = try await firstAsset() {
                    guard AudioControlPlaybackRequestPolicy.shouldApplyNavigationResult(
                        requestedAsset: asset,
                        currentAsset: man.currentAsset,
                        isSceneActive: shouldActivateControl || ignoreSceneCheck,
                        currentGeneration: controlGeneration,
                        requestGeneration: generation
                    ) else {
                        return
                    }
                    alert_info(String(localized: "Reached the last track, playing the first", bundle: .module))
                    await man.play(first, autoPlay: true, reason: "AudioControlRootView.loop")
                } else {
                    guard AudioControlPlaybackRequestPolicy.shouldApplyNavigationResult(
                        requestedAsset: asset,
                        currentAsset: man.currentAsset,
                        isSceneActive: shouldActivateControl || ignoreSceneCheck,
                        currentGeneration: controlGeneration,
                        requestGeneration: generation
                    ) else {
                        return
                    }
                    await man.reset(reason: "AudioControlRootView.emptyLibrary")
                    alert_info(String(localized: "No files in library", bundle: .module))
                }
            } catch {
                guard AudioControlPlaybackRequestPolicy.shouldReportNavigationFailure(
                    requestedAsset: asset,
                    currentAsset: man.currentAsset,
                    isSceneActive: shouldActivateControl || ignoreSceneCheck,
                    currentGeneration: controlGeneration,
                    requestGeneration: generation
                ) else {
                    return
                }
                if AudioControlRuntime.verbose {
                    AudioControlRuntime.log.error("Failed to get next asset: \(error.localizedDescription)")
                }
                alert_error(String(localized: "Cannot play next: \(error.localizedDescription)", bundle: .module))
            }
        }
    }

    func handleStorageLocationDidReset() {
        guard AudioControlPlaybackRequestPolicy.shouldResetForStorageLocationChange(isSceneActive: shouldActivateControl) else {
            return
        }

        let generation = controlGeneration
        Task { @MainActor in
            guard AudioControlPlaybackRequestPolicy.shouldApplyStorageReset(
                currentGeneration: controlGeneration,
                requestGeneration: generation,
                isSceneActive: shouldActivateControl
            ) else {
                return
            }

            await man.reset(reason: "AudioControlRootView.storageLocationDidReset")
        }
    }

    func handleDBDeleted(_ notification: Notification) {
        guard let urlsToDelete = notification.userInfo?["urls"] as? [URL],
              AudioControlPlaybackRequestPolicy.currentAssetAffectedByDeletion(
                  currentAsset: man.asset,
                  deletedURLs: urlsToDelete
              ) else {
            return
        }

        let generation = controlGeneration
        Task { @MainActor in
            guard AudioControlPlaybackRequestPolicy.currentAssetAffectedByDeletion(
                currentAsset: man.asset,
                deletedURLs: urlsToDelete
            ) else {
                return
            }

            guard shouldActivateControl else {
                guard AudioControlPlaybackRequestPolicy.shouldApplyDeletionRecovery(
                    currentAsset: man.asset,
                    deletedURLs: urlsToDelete,
                    currentGeneration: controlGeneration,
                    requestGeneration: generation
                ) else {
                    return
                }
                await man.reset(reason: "AudioControlRootView.deletedCurrentAsset")
                return
            }

            do {
                if let first = try await firstAsset() {
                    guard AudioControlPlaybackRequestPolicy.shouldApplyDeletionRecovery(
                        currentAsset: man.asset,
                        deletedURLs: urlsToDelete,
                        currentGeneration: controlGeneration,
                        requestGeneration: generation
                    ) else {
                        return
                    }
                    alert_warning(String(localized: "Current file was deleted, playing the first", bundle: .module))
                    await man.play(first, autoPlay: true, reason: "AudioControlRootView")
                } else {
                    guard AudioControlPlaybackRequestPolicy.shouldApplyDeletionRecovery(
                        currentAsset: man.asset,
                        deletedURLs: urlsToDelete,
                        currentGeneration: controlGeneration,
                        requestGeneration: generation
                    ) else {
                        return
                    }
                    await man.reset(reason: "AudioControlRootView.emptyLibrary")
                    alert_info(String(localized: "No files in library", bundle: .module))
                }
            } catch {
                guard AudioControlPlaybackRequestPolicy.shouldApplyDeletionRecovery(
                    currentAsset: man.asset,
                    deletedURLs: urlsToDelete,
                    currentGeneration: controlGeneration,
                    requestGeneration: generation
                ) else {
                    return
                }
                await man.reset(reason: "AudioControlRootView.getFirstFailed")
                alert_error(String(localized: "Cannot play next: \(error.localizedDescription)", bundle: .module))
            }
        }
    }
}

private extension Notification.Name {
    static let audioControlDBDeleted = Notification.Name("dbDeleted")
    static let audioControlStorageLocationDidReset = Notification.Name("storageLocationDidReset")
}
