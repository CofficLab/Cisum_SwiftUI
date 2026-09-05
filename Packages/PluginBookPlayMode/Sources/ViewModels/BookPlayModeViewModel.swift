import Foundation
import Combine
import MagicAlert
import MagicPlayMan
import ProviderPlayback
import ProviderScene

typealias BookPlayModeLoadAction = @MainActor () async -> MagicPlayMode
typealias BookPlayModeStoreAction = @MainActor (_ mode: MagicPlayMode) async -> Void

@MainActor
final class BookPlayModeViewModel: ObservableObject {
    private let playbackCapability: (any BookPlayModePlaybackCapability)?
    private let targetScene: AppScene
    private let loadPlayMode: BookPlayModeLoadAction
    private let storePlayMode: BookPlayModeStoreAction
    private var currentScene: AppScene?
    private var generation = 0
    private var isActive = false

    init(
        targetScene: AppScene = .audiobooks,
        playbackCapability: (any BookPlayModePlaybackCapability)?,
        loadPlayMode: @escaping BookPlayModeLoadAction,
        storePlayMode: @escaping BookPlayModeStoreAction
    ) {
        self.targetScene = targetScene
        self.playbackCapability = playbackCapability
        self.loadPlayMode = loadPlayMode
        self.storePlayMode = storePlayMode
    }

    func handleSceneChange(_ scene: AppScene?) {
        currentScene = scene
        if scene == targetScene { activate() }
        else { generation += 1; isActive = false }
    }

    func handlePlaybackEvent(_ event: PlaybackProvidingEvent) {
        guard case .playModeChanged(let mode) = event, isActive else { return }
        generation += 1
        let requestGeneration = generation
        Task { @MainActor [weak self] in
            guard let self, self.isActive, self.generation == requestGeneration else { return }
            await storePlayMode(mode)
            switch mode {
            case .loop: alert_info(String(localized: "Repeat One", bundle: .module))
            case .sequence, .repeatAll: alert_info(String(localized: "Sequential Play", bundle: .module))
            case .shuffle: alert_info(String(localized: "Shuffle", bundle: .module))
            }
        }
    }

    private func activate() {
        guard !isActive, currentScene == targetScene, let playbackCapability else { return }
        isActive = true
        let requestGeneration = generation
        Task { @MainActor [weak self] in
            guard let self, let playback = playbackCapability else { return }
            let storedMode = await loadPlayMode()
            guard self.isActive, self.generation == requestGeneration, storedMode != playback.playMode else { return }
            playback.setPlayMode(storedMode)
        }
    }
}
