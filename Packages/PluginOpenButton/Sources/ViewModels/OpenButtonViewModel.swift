import Combine
import Foundation
import ProviderPlayback

@MainActor
final class OpenButtonViewModel: ObservableObject {
    @Published private(set) var url: URL?

    func bind(playback: any PlaybackProviding) {
        url = playback.currentURL
    }

    func handlePlaybackEvent(_ event: PlaybackProvidingEvent) {
        if case .assetChanged(let url) = event { self.url = url }
    }
}
