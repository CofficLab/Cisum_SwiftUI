import Combine
import Foundation
import MagicKit

@MainActor
final class OpenButtonViewModel: ObservableObject, SuperLog {
    nonisolated static let verbose = false

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
