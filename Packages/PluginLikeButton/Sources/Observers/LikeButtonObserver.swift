import Foundation
import ProviderPlayback

@MainActor
final class LikeButtonObserver {
    private weak var viewModel: LikeButtonViewModel?
    private var handle: (any PlaybackProvidingObserverHandle)?

    init(playback: any PlaybackProviding, viewModel: LikeButtonViewModel) {
        self.viewModel = viewModel
        handle = playback.addObserver { [weak self] event in
            switch event {
            case .assetChanged(let url):
                self?.viewModel?.handleAssetChanged(url)
            case .likeStatusChanged(_, let liked):
                self?.viewModel?.handleLikeStatusChanged(liked)
            case .likedAssetsChanged(let assets):
                self?.viewModel?.handleLikedAssetsChanged(Array(assets))
            default:
                break
            }
        }
    }

    func cancel() {
        handle?.cancel()
        handle = nil
    }
}
