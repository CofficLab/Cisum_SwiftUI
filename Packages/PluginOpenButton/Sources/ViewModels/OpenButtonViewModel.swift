import Combine
import Foundation
import ProviderPlayback

@MainActor
final class OpenButtonViewModel: ObservableObject {
    @Published private(set) var url: URL?
    private let playbackCapability: (any OpenButtonPlaybackCapability)?

    init(playbackCapability: (any OpenButtonPlaybackCapability)?) {
        self.playbackCapability = playbackCapability
        url = playbackCapability?.currentURL
    }

    func handlePlaybackEvent(_ event: PlaybackProvidingEvent) {
        if case .assetChanged(let url) = event { self.url = url }
    }
}
