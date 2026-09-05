import Combine
import MagicPlayMan
import ProviderPlayback

@MainActor
final class LikeButtonViewModel: ObservableObject {
    @Published private(set) var hasAsset = false
    @Published private(set) var isLiked = false
    private weak var playback: (any PlaybackProviding)?

    func bind(playback: any PlaybackProviding) {
        self.playback = playback
        hasAsset = playback.hasAsset
        isLiked = playback.currentURL.map { playback.likedAssets.contains($0) } ?? false
    }

    func handlePlaybackEvent(_ event: PlaybackProvidingEvent) {
        switch event {
        case .stateChanged: break
        case .assetChanged(let url):
            hasAsset = url != nil
            isLiked = url.map { playback?.likedAssets.contains($0) ?? false } ?? false
        case .likeStatusChanged(_, let liked): isLiked = liked
        case .likedAssetsChanged(let assets):
            isLiked = playback?.currentURL.map { assets.contains($0) } ?? false
        default: break
        }
    }

    func toggleLike() { playback?.toggleCurrentLike() }
}
