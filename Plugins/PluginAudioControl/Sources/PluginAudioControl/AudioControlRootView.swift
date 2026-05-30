import Foundation
import MagicAlert
import MagicPlayMan
import OSLog
import SwiftUI

public typealias AudioControlAdjacentAssetProvider = @MainActor (_ current: URL?, _ verbose: Bool) async throws -> URL?
public typealias AudioControlFirstAssetProvider = @MainActor () async throws -> URL?
public typealias AudioControlLastAssetProvider = @MainActor () async throws -> URL?
public typealias AudioControlCurrentSceneProvider = @MainActor () -> String?

private enum AudioControlRuntime {
    static let verbose = true
    static let log = Logger(subsystem: "com.yueyi.cisum", category: "AudioControl")
    static let author = "AudioControlRootView"
}

enum AudioControlPlaybackRequestPolicy {
    static func shouldApplyNavigationResult(requestedAsset: URL, currentAsset: URL?) -> Bool {
        currentAsset == requestedAsset
    }

    static func currentAssetAffectedByDeletion(currentAsset: URL?, deletedURLs: [URL]) -> Bool {
        guard let currentAsset else { return false }
        let currentPath = currentAsset.standardizedFileURL.path
        return deletedURLs.contains { deletedURL in
            deletedURL.standardizedFileURL.path == currentPath
        }
    }
}

public struct AudioControlRootView<Content>: View where Content: View {
    @EnvironmentObject private var man: MagicPlayMan
    @State private var playbackSubscriptionID: UUID?

    private let content: Content
    private let targetSceneName: String
    private let currentSceneName: AudioControlCurrentSceneProvider
    private let nextAsset: AudioControlAdjacentAssetProvider
    private let previousAsset: AudioControlAdjacentAssetProvider
    private let firstAsset: AudioControlFirstAssetProvider
    private let lastAsset: AudioControlLastAssetProvider

    public init(
        targetSceneName: String,
        currentSceneName: @escaping AudioControlCurrentSceneProvider,
        nextAsset: @escaping AudioControlAdjacentAssetProvider,
        previousAsset: @escaping AudioControlAdjacentAssetProvider,
        firstAsset: @escaping AudioControlFirstAssetProvider,
        lastAsset: @escaping AudioControlLastAssetProvider,
        @ViewBuilder content: () -> Content
    ) {
        self.targetSceneName = targetSceneName
        self.currentSceneName = currentSceneName
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
            .onChange(of: currentSceneName()) { _, newSceneName in
                handleCurrentSceneChanged(newSceneName)
            }
            .onReceive(NotificationCenter.default.publisher(for: .audioControlDBDeleted), perform: handleDBDeleted)
            .onReceive(NotificationCenter.default.publisher(for: .audioControlStorageLocationDidReset)) { _ in
                handleStorageLocationDidReset()
            }
    }

    private var shouldActivateControl: Bool {
        currentSceneName() == targetSceneName
    }
}

private extension AudioControlRootView {
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
        guard let playbackSubscriptionID else { return }

        man.unsubscribe(playbackSubscriptionID)
        self.playbackSubscriptionID = nil
    }

    func handlePreviousRequested(_ asset: URL, ignoreSceneCheck: Bool = false) {
        guard shouldActivateControl || ignoreSceneCheck else { return }

        Task { @MainActor in
            do {
                if let previous = try await previousAsset(asset, false) {
                    guard AudioControlPlaybackRequestPolicy.shouldApplyNavigationResult(
                        requestedAsset: asset,
                        currentAsset: man.currentAsset
                    ) else {
                        return
                    }
                    await man.play(previous, autoPlay: true, reason: "AudioControlRootView")
                    return
                }

                if man.playMode == .repeatAll, let last = try await lastAsset() {
                    guard AudioControlPlaybackRequestPolicy.shouldApplyNavigationResult(
                        requestedAsset: asset,
                        currentAsset: man.currentAsset
                    ) else {
                        return
                    }
                    await man.play(last, autoPlay: true, reason: "AudioControlRootView.repeatAllPrevious")
                } else if man.playMode == .repeatAll {
                    await man.reset(reason: "AudioControlRootView.emptyLibrary")
                    alert_info(String(localized: "No files in library", table: "Audio-Control", bundle: .module))
                }
            } catch {
                if AudioControlRuntime.verbose {
                    AudioControlRuntime.log.error("Failed to get previous asset: \(error.localizedDescription)")
                }
                alert_error(String(localized: "Cannot play previous: \(error.localizedDescription)", table: "Audio-Control", bundle: .module))
            }
        }
    }

    func handleNextRequested(_ asset: URL, ignoreSceneCheck: Bool = false) {
        guard shouldActivateControl || ignoreSceneCheck else { return }

        Task { @MainActor in
            do {
                if let next = try await nextAsset(asset, AudioControlRuntime.verbose) {
                    guard AudioControlPlaybackRequestPolicy.shouldApplyNavigationResult(
                        requestedAsset: asset,
                        currentAsset: man.currentAsset
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
                        currentAsset: man.currentAsset
                    ) else {
                        return
                    }
                    alert_info(String(localized: "Reached the last track, playing the first", table: "Audio-Control", bundle: .module))
                    await man.play(first, autoPlay: true, reason: "AudioControlRootView.loop")
                } else {
                    await man.reset(reason: "AudioControlRootView.emptyLibrary")
                    alert_info(String(localized: "No files in library", table: "Audio-Control", bundle: .module))
                }
            } catch {
                if AudioControlRuntime.verbose {
                    AudioControlRuntime.log.error("Failed to get next asset: \(error.localizedDescription)")
                }
                alert_error(String(localized: "Cannot play next: \(error.localizedDescription)", table: "Audio-Control", bundle: .module))
            }
        }
    }

    func handleStorageLocationDidReset() {
        Task { @MainActor in
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

        Task { @MainActor in
            guard AudioControlPlaybackRequestPolicy.currentAssetAffectedByDeletion(
                currentAsset: man.asset,
                deletedURLs: urlsToDelete
            ) else {
                return
            }

            guard shouldActivateControl else {
                await man.reset(reason: "AudioControlRootView.deletedCurrentAsset")
                return
            }

            do {
                if let first = try await firstAsset() {
                    alert_warning(String(localized: "Current file was deleted, playing the first", table: "Audio-Control", bundle: .module))
                    await man.play(first, autoPlay: true, reason: "AudioControlRootView")
                } else {
                    await man.reset(reason: "AudioControlRootView.emptyLibrary")
                    alert_info(String(localized: "No files in library", table: "Audio-Control", bundle: .module))
                }
            } catch {
                await man.reset(reason: "AudioControlRootView.getFirstFailed")
                alert_error(String(localized: "Cannot play next: \(error.localizedDescription)", table: "Audio-Control", bundle: .module))
            }
        }
    }
}

private extension Notification.Name {
    static let audioControlDBDeleted = Notification.Name("dbDeleted")
    static let audioControlStorageLocationDidReset = Notification.Name("storageLocationDidReset")
}
