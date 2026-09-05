import ProviderPlayback

/// 播放封面观察者：订阅 `PlaybackProviding` 并驱动封面 ViewModel。
@MainActor
final class PlaybackHeroObserver {
    private weak var viewModel: PlaybackHeroViewModel?
    private var handle: (any PlaybackProvidingObserverHandle)?

    init(playback: (any PlaybackProviding)?, viewModel: PlaybackHeroViewModel) {
        self.viewModel = viewModel
        handle = playback?.addObserver { [weak self] event in
            self?.viewModel?.handlePlaybackEvent(event)
        }
    }

    func cancel() {
        handle?.cancel()
        handle = nil
    }
}
