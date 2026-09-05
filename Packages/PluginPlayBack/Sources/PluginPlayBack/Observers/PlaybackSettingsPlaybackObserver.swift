import ProviderPlayback

/// 播放设置页的播放状态观察者：把播放详情转发给设置页 ViewModel。
@MainActor
final class PlaybackSettingsPlaybackObserver {
    private weak var viewModel: PluginPlayBackSettingsViewModel?
    private var handle: (any PlaybackProvidingObserverHandle)?

    init(playback: (any PlaybackProviding)?, viewModel: PluginPlayBackSettingsViewModel) {
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
