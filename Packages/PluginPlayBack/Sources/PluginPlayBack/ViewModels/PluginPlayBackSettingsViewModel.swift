import Foundation
import MagicPlayMan
import ProviderPlayback
import ProviderScene

/// 播放设置页的场景化 ViewModel：维护当前场景与各场景最近播放文件。
///
/// 内核存在场景概念（`AppScene` 固定枚举，如「音乐库」「有声书」），因此设置页
/// 不再只展示单一全局当前文件，而是按场景展示：每个场景各自记住上次播放的文件。
/// 场景切换由 `PlaybackSettingsSceneObserver` 转发到 `handleSceneChanged(_:)`。
@MainActor
final class PluginPlayBackSettingsViewModel: ObservableObject {
    /// 所有内置场景（固定顺序，即 `AppScene.allCases`）。
    let scenes: [AppScene] = AppScene.allCases

    /// 当前激活场景；`nil` 表示场景尚未恢复。
    @Published private(set) var currentScene: AppScene?
    @Published private(set) var currentURL: URL?
    @Published private(set) var isPlaying = false
    @Published private(set) var state: PlaybackState = .idle
    @Published private(set) var currentTime: TimeInterval = 0
    @Published private(set) var duration: TimeInterval = 0

    private let store: PlaybackStateStore

    init(store: PlaybackStateStore, playback: (any PlaybackProviding)? = nil) {
        self.store = store
        currentURL = playback?.currentURL
        isPlaying = playback?.isPlaying ?? false
        state = playback?.state ?? .idle
        currentTime = playback?.currentTime ?? 0
        duration = playback?.duration ?? 0
    }

    func handleSceneChanged(_ scene: AppScene?) {
        currentScene = scene
    }

    func handlePlaybackEvent(_ event: PlaybackProvidingEvent) {
        switch event {
        case .assetChanged(let url): currentURL = url
        case .stateChanged(let state):
            self.state = state
            isPlaying = state == .playing
        case .timeChanged(let currentTime, _): self.currentTime = currentTime
        case .durationChanged(let duration): self.duration = duration
        default: break
        }
    }

    /// 指定场景最近播放的文件；无记录时返回 `nil`。
    func lastFile(for scene: AppScene) -> URL? {
        store.loadCurrentFile(for: scene)
    }
}
