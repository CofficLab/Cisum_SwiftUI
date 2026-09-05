import MagicPlayMan
import ProviderPlayback
import SwiftUI

/// 播放封面区域的状态；播放变化由 Observer 转发，媒体视图由兼容构建器提供。
@MainActor
final class PlaybackHeroViewModel: ObservableObject {
    @Published private(set) var currentURL: URL?
    @Published private(set) var state: PlaybackState

    private let mediaViewBuilder: @MainActor () -> AnyView
    private let stateText: @MainActor (PlaybackState) -> String

    init(
        playback: (any PlaybackProviding)?,
        mediaViewBuilder: @escaping @MainActor () -> AnyView,
        stateText: @escaping @MainActor (PlaybackState) -> String
    ) {
        self.currentURL = playback?.currentURL
        self.state = playback?.state ?? .idle
        self.mediaViewBuilder = mediaViewBuilder
        self.stateText = stateText
    }

    func handlePlaybackEvent(_ event: PlaybackProvidingEvent) {
        switch event {
        case .assetChanged(let url): currentURL = url
        case .stateChanged(let state): self.state = state
        default: break
        }
    }

    func makeMediaView() -> AnyView {
        mediaViewBuilder()
    }

    func localizedStateText() -> String {
        stateText(state)
    }
}
