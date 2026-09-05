import Combine
import Foundation

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

    func handleAssetChanged(_ url: URL?) {
        hasAsset = url != nil
        isLiked = url.map { playbackCapability?.likedAssets.contains($0) ?? false } ?? false
    }

    func handleLikeStatusChanged(_ liked: Bool) {
        isLiked = liked
    }

    func handleLikedAssetsChanged(_ assets: [URL]) {
        isLiked = playbackCapability?.currentURL.map { assets.contains($0) } ?? false
    }

    func toggleLike() { playbackCapability?.toggleCurrentLike() }
}
