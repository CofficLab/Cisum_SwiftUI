import ProviderPlayback
import MagicKit

/// 音频库播放状态观察者：将播放服务的当前资源变化转发给列表 ViewModel。
@MainActor
final class AudioDBPlaybackObserver: SuperLog {
    nonisolated static let verbose = false

    private weak var viewModel: AudioListViewModel?
    private var handle: (any PlaybackProvidingObserverHandle)?

    init(playback: (any PlaybackProviding)?, viewModel: AudioListViewModel) {
        self.viewModel = viewModel
        viewModel.applyExternalPlayback(url: playback?.currentURL)
        handle = playback?.addObserver { [weak self] event in
            guard case .assetChanged(let url) = event else { return }
            self?.viewModel?.applyExternalPlayback(url: url)
        }
    }

    func cancel() {
        handle?.cancel()
        handle = nil
    }
}
