import ProviderPlayback
import ProviderScene

@MainActor
final class BookPlayModeObserver {
    private weak var viewModel: BookPlayModeViewModel?
    private var sceneHandle: (any SceneProvidingObserverHandle)?
    private var playbackHandle: (any PlaybackProvidingObserverHandle)?

    init(scene: any SceneProviding, playback: any PlaybackProviding, viewModel: BookPlayModeViewModel) {
        self.viewModel = viewModel
        viewModel.handleSceneChange(scene.currentScene)
        sceneHandle = scene.addObserver { [weak self] event in
            guard case .selectionChanged(let scene) = event else { return }
            self?.viewModel?.handleSceneChange(scene)
        }
        playbackHandle = playback.addObserver { [weak self] event in
            self?.viewModel?.handlePlaybackEvent(event)
        }
    }

    func cancel() {
        sceneHandle?.cancel()
        sceneHandle = nil
        playbackHandle?.cancel()
        playbackHandle = nil
    }
}
