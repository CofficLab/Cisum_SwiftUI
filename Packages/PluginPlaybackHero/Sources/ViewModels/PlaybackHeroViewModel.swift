import MagicPlayMan
import SwiftUI

/// 播放封面区域的状态；播放变化由 Observer 转发，媒体视图由 Capability 提供。
@MainActor
final class PlaybackHeroViewModel: ObservableObject {
    @Published private(set) var currentURL: URL?
    @Published private(set) var state: PlaybackState

    private let playbackCapability: (any PlaybackHeroPlaybackCapability)?

    init(playbackCapability: (any PlaybackHeroPlaybackCapability)?) {
        self.playbackCapability = playbackCapability
        self.currentURL = playbackCapability?.currentURL
        self.state = playbackCapability?.state ?? .idle
    }

    func applyAssetChanged(_ url: URL?) {
        currentURL = url
    }

    func applyStateChanged(_ state: PlaybackState) {
        self.state = state
    }

    func makeMediaView() -> AnyView {
        playbackCapability?.makeHeroView() ?? AnyView(EmptyView())
    }

    func localizedStateText() -> String {
        playbackCapability?.localizedStateText(for: state) ?? String(describing: state)
    }
}
