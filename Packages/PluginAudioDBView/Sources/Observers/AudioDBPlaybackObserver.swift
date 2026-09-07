import ProviderPlayback
import MagicKit
import OSLog

/// 音频库播放状态观察者：将播放服务的当前资源变化转发给列表 ViewModel。
@MainActor
final class AudioDBPlaybackObserver: SuperLog {
    nonisolated static let verbose = true

    private weak var viewModel: AudioListViewModel?
    private var handle: (any PlaybackProvidingObserverHandle)?

    init(playback: (any PlaybackProviding)?, viewModel: AudioListViewModel) {
        self.viewModel = viewModel
        os_log("[AudioDBPlayback] registering playback observer; playback available=%{public}s", playback == nil ? "false" : "true")
        viewModel.applyExternalPlayback(url: playback?.currentURL)
        handle = playback?.addObserver { [weak self] event in
            guard case .assetChanged(let url) = event else { return }
            os_log("[AudioDBPlayback] received assetChanged event: %{public}s", url?.path ?? "nil")
            self?.viewModel?.applyExternalPlayback(url: url)
        }
        os_log("[AudioDBPlayback] playback observer registration completed")
    }

    func cancel() {
        os_log("[AudioDBPlayback] cancelling playback observer")
        handle?.cancel()
        handle = nil
    }
}
