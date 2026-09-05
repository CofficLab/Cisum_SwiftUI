import Foundation
import Combine
import MagicAlert
import MagicPlayMan
import OSLog
import ProviderScene
import MagicKit

typealias AudioPlayModeSortAction = @MainActor (_ currentURL: URL?) async throws -> Void
typealias AudioPlayModeShuffleAction = @MainActor (_ currentURL: URL?) async throws -> Void
typealias AudioPlayModeLoadAction = @MainActor () async -> MagicPlayMode
typealias AudioPlayModeStoreAction = @MainActor (_ rawValue: String, _ shortName: String) async -> Void

@MainActor
final class AudioPlayModeViewModel: ObservableObject, SuperLog {
    nonisolated static let verbose = false

    private static let log = Logger(subsystem: "com.yueyi.cisum", category: "AudioPlayMode")
    private let playbackCapability: (any AudioPlayModePlaybackCapability)?
    private let targetScene: AppScene
    private let sort: AudioPlayModeSortAction
    private let shuffle: AudioPlayModeShuffleAction
    private let loadPlayMode: AudioPlayModeLoadAction
    private let storePlayMode: AudioPlayModeStoreAction
    private var currentScene: AppScene?
    private var generation = 0
    private var isActive = false

    init(
        targetScene: AppScene = .music,
        playbackCapability: (any AudioPlayModePlaybackCapability)?,
        sort: @escaping AudioPlayModeSortAction,
        shuffle: @escaping AudioPlayModeShuffleAction,
        loadPlayMode: @escaping AudioPlayModeLoadAction,
        storePlayMode: @escaping AudioPlayModeStoreAction
    ) {
        self.targetScene = targetScene
        self.playbackCapability = playbackCapability
        self.sort = sort
        self.shuffle = shuffle
        self.loadPlayMode = loadPlayMode
        self.storePlayMode = storePlayMode
    }

    func handleSceneChange(_ scene: AppScene?) {
        currentScene = scene
        if scene == targetScene { activate() }
        else { generation += 1; isActive = false }
    }

    func applyPlayModeChanged(_ mode: MagicPlayMode) {
        handlePlayModeChanged(mode)
    }

    private func activate() {
        guard !isActive, currentScene == targetScene, let playbackCapability else { return }
        isActive = true
        let requestGeneration = generation
        Task { @MainActor [weak self] in
            guard let self else { return }
            let storedMode = await loadPlayMode()
            guard self.isActive, self.generation == requestGeneration, storedMode != playbackCapability.playMode else { return }
            playbackCapability.setPlayMode(storedMode)
        }
    }

    private func handlePlayModeChanged(_ mode: MagicPlayMode) {
        guard isActive, let playbackCapability else { return }
        generation += 1
        let requestGeneration = generation
        let currentURL = playbackCapability.currentURL
        let modeRawValue = mode.rawValue

        Task { @MainActor [weak self] in
            guard let self, self.isActive, self.generation == requestGeneration else { return }
            await storePlayMode(modeRawValue, mode.shortName)
        }
        Task { @MainActor [weak self] in
            guard let self, self.isActive, self.generation == requestGeneration,
                  playbackCapability.playMode.rawValue == modeRawValue else { return }
            do {
                switch mode {
                case .loop: alert_info(String(localized: "Repeat One", bundle: .module))
                case .sequence, .repeatAll:
                    alert_info(String(localized: "Sequential Play", bundle: .module))
                    try await self.sort(currentURL)
                case .shuffle:
                    alert_info(String(localized: "Shuffle", bundle: .module))
                    try await self.shuffle(currentURL)
                }
            } catch {
                guard self.isActive, self.generation == requestGeneration else { return }
                Self.log.error("Failed to update audio play queue: \(error.localizedDescription)")
                alert_error(String(localized: "Cannot update play queue: \(error.localizedDescription)", bundle: .module))
            }
        }
    }
}
