import ProviderPlayback

/// 播放进度观察者：订阅 `PlaybackProviding` 并更新插件 ViewModel。
@MainActor
final class PlaybackProgressObserver {
    private weak var viewModel: PlaybackProgressViewModel?
    private var handle: (any PlaybackProvidingObserverHandle)?

    init(playback: (any PlaybackProviding)?, viewModel: PlaybackProgressViewModel) {
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
