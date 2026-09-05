import ProviderPlayback
import MagicKit

/// 有声书库播放状态观察者：把当前章节变化转发到网格 ViewModel。
@MainActor
final class BookDBPlaybackObserver: SuperLog {
    nonisolated static let verbose = false

    private weak var viewModel: BookGridViewModel?
    private var handle: (any PlaybackProvidingObserverHandle)?

    init(playback: (any PlaybackProviding)?, viewModel: BookGridViewModel) {
        self.viewModel = viewModel
        viewModel.handleAssetChanged(playback?.currentURL)
        handle = playback?.addObserver { [weak self] event in
            guard case .assetChanged(let url) = event else { return }
            self?.viewModel?.handleAssetChanged(url)
        }
    }

    func cancel() {
        handle?.cancel()
        handle = nil
    }
}
