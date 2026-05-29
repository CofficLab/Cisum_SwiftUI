import Foundation
import MagicAlert
import MagicPlayMan
import OSLog
import SwiftUI

public typealias AudioControlAdjacentAssetProvider = @MainActor (_ current: URL?, _ verbose: Bool) async throws -> URL?
public typealias AudioControlFirstAssetProvider = @MainActor () async throws -> URL?
public typealias AudioControlCurrentSceneProvider = @MainActor () -> String?

private enum AudioControlRuntime {
    static let verbose = true
    static let log = Logger(subsystem: "com.yueyi.cisum", category: "AudioControl")
    static let author = "AudioControlRootView"
}

public struct AudioControlRootView<Content>: View where Content: View {
    @EnvironmentObject private var man: MagicPlayMan

    private let content: Content
    private let targetSceneName: String
    private let currentSceneName: AudioControlCurrentSceneProvider
    private let nextAsset: AudioControlAdjacentAssetProvider
    private let previousAsset: AudioControlAdjacentAssetProvider
    private let firstAsset: AudioControlFirstAssetProvider

    public init(
        targetSceneName: String,
        currentSceneName: @escaping AudioControlCurrentSceneProvider,
        nextAsset: @escaping AudioControlAdjacentAssetProvider,
        previousAsset: @escaping AudioControlAdjacentAssetProvider,
        firstAsset: @escaping AudioControlFirstAssetProvider,
        @ViewBuilder content: () -> Content
    ) {
        self.targetSceneName = targetSceneName
        self.currentSceneName = currentSceneName
        self.nextAsset = nextAsset
        self.previousAsset = previousAsset
        self.firstAsset = firstAsset
        self.content = content()
    }

    public var body: some View {
        content
            .onAppear(perform: handleOnAppear)
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
        guard shouldActivateControl else {
            if AudioControlRuntime.verbose {
                AudioControlRuntime.log.debug("Skip playback control because current scene is not audio")
            }
            return
        }

        man.subscribe(
            name: AudioControlRuntime.author,
            onPreviousRequested: { asset in
                handlePreviousRequested(asset)
            },
            onNextRequested: { asset in
                handleNextRequested(asset)
            }
        )
    }

    func handlePreviousRequested(_ asset: URL, ignoreSceneCheck: Bool = false) {
        guard shouldActivateControl || ignoreSceneCheck else { return }

        Task { @MainActor in
            do {
                if let previous = try await previousAsset(asset, false) {
                    await man.play(previous, autoPlay: true, reason: "AudioControlRootView")
                }
            } catch {
                if AudioControlRuntime.verbose {
                    AudioControlRuntime.log.error("Failed to get previous asset: \(error.localizedDescription)")
                }
            }
        }
    }

    func handleNextRequested(_ asset: URL, ignoreSceneCheck: Bool = false) {
        guard shouldActivateControl || ignoreSceneCheck else { return }

        Task { @MainActor in
            do {
                if let next = try await nextAsset(asset, AudioControlRuntime.verbose) {
                    await man.play(next, autoPlay: true, reason: "AudioControlRootView.handleNextRequested")
                    return
                }

                if let first = try await firstAsset() {
                    alert_info(String(localized: "Reached the last track, playing the first", table: "Audio-Control", bundle: .module))
                    await man.play(first, autoPlay: true, reason: "AudioControlRootView.loop")
                } else {
                    await man.stop(reason: "AudioControlRootView.emptyLibrary")
                    alert_info(String(localized: "No files in library", table: "Audio-Control", bundle: .module))
                }
            } catch {
                if AudioControlRuntime.verbose {
                    AudioControlRuntime.log.error("Failed to get next asset: \(error.localizedDescription)")
                }
            }
        }
    }

    func handleStorageLocationDidReset() {
        guard shouldActivateControl else { return }
        man.pause(reason: "AudioControlRootView.storageLocationDidReset")
    }

    func handleDBDeleted(_ notification: Notification) {
        guard shouldActivateControl else { return }

        guard let urlsToDelete = notification.userInfo?["urls"] as? [URL],
              let currentAsset = man.asset,
              urlsToDelete.contains(currentAsset) else {
            return
        }

        Task { @MainActor in
            do {
                if let first = try await firstAsset() {
                    alert_warning(String(localized: "Current file was deleted, playing the first", table: "Audio-Control", bundle: .module))
                    await man.play(first, autoPlay: true, reason: "AudioControlRootView")
                } else {
                    await man.stop(reason: "AudioControlRootView.emptyLibrary")
                    alert_info(String(localized: "No files in library", table: "Audio-Control", bundle: .module))
                }
            } catch {
                await man.stop(reason: "AudioControlRootView.getFirstFailed")
                alert_error(String(localized: "Cannot play next: \(error.localizedDescription)", table: "Audio-Control", bundle: .module))
            }
        }
    }
}

private extension Notification.Name {
    static let audioControlDBDeleted = Notification.Name("dbDeleted")
    static let audioControlStorageLocationDidReset = Notification.Name("storageLocationDidReset")
}
