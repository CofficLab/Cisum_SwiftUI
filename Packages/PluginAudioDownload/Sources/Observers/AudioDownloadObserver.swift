import ProviderPlayback
import ProviderScene

@MainActor
final class AudioDownloadObserver {
    private weak var viewModel: AudioDownloadViewModel?
    private var sceneHandle: (any SceneProvidingObserverHandle)?
    private var playbackHandle: (any PlaybackProvidingObserverHandle)?

    init(scene: any SceneProviding, playback: any PlaybackProviding, viewModel: AudioDownloadViewModel) {
        self.viewModel = viewModel
        viewModel.bind(playback: playback)
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
