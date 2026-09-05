import Combine
import Foundation

@MainActor
final class OpenButtonViewModel: ObservableObject {
    @Published private(set) var url: URL?
    private let playbackCapability: (any OpenButtonPlaybackCapability)?

    init(playbackCapability: (any OpenButtonPlaybackCapability)?) {
        self.playbackCapability = playbackCapability
        url = playbackCapability?.currentURL
    }

    func handleAssetChanged(_ url: URL?) {
        self.url = url
    }
}
