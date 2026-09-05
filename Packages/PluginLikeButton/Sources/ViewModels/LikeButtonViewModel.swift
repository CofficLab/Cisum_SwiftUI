import Combine
import Foundation
import ProviderPlayback

@MainActor
final class LikeButtonViewModel: ObservableObject {
    @Published private(set) var hasAsset = false
    @Published private(set) var isLiked = false
    private let playbackCapability: (any LikeButtonPlaybackCapability)?

    init(playbackCapability: (any LikeButtonPlaybackCapability)?) {
        self.playbackCapability = playbackCapability
        hasAsset = playbackCapability?.hasAsset ?? false
        isLiked = playbackCapability?.currentURL.map { playbackCapability?.likedAssets.contains($0) ?? false } ?? false
    }

    func handlePlaybackEvent(_ event: PlaybackProvidingEvent) {
        switch event {
        case .stateChanged: break
        case .assetChanged(let url):
            hasAsset = url != nil
            isLiked = url.map { playbackCapability?.likedAssets.contains($0) ?? false } ?? false
        case .likeStatusChanged(_, let liked): isLiked = liked
        case .likedAssetsChanged(let assets):
            isLiked = playbackCapability?.currentURL.map { assets.contains($0) } ?? false
        default: break
        }
    }

    func toggleLike() { playbackCapability?.toggleCurrentLike() }
}
