import ProviderPlayback

/// 音频库播放状态观察者：将播放服务的当前资源变化转发给列表 ViewModel。
@MainActor
final class AudioDBPlaybackObserver {
    private weak var viewModel: AudioListViewModel?
    private var handle: (any PlaybackProvidingObserverHandle)?

    init(playback: (any PlaybackProviding)?, viewModel: AudioListViewModel) {
        self.viewModel = viewModel
        viewModel.handleAssetChanged(url: playback?.currentURL)
        handle = playback?.addObserver { [weak self] event in
            guard case .assetChanged(let url) = event else { return }
            self?.viewModel?.handleAssetChanged(url: url)
        }
    }

    func cancel() {
        handle?.cancel()
        handle = nil
    }
}
