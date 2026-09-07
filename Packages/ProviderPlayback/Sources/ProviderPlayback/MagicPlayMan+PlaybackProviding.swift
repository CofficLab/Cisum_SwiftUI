import Combine
import Foundation
import MagicPlayMan
import OSLog

/// 将 `MagicPlayMan` 桥接为内核的 `PlaybackProviding`。
///
/// 此一致性声明在 `FactoryCisum` 中（而非 `MagicPlayMan` 包内），以避免
/// `MagicPlayMan → CisumKernel → MagicPlayMan` 的循环依赖。`MagicPlayMan`
/// 自身是 `@MainActor ObservableObject`，其 `@Published` 状态（`state`、
/// `currentURL`、`currentTime`、`duration`、`progress`、`playMode`、`likedAssets`）
/// 与 `hasAsset`、`next()`、`previous()`、`togglePlayMode()` 直接满足协议要求；
/// 这里只补齐少数签名不同的传输控制方法，内部调用 `MagicPlayMan` 真实 API
/// （`reason` 日志标签使用本桥接的固定标识）。
///
/// 协议对外的唯一通知方式是 `addObserver`（`PlaybackProvidingEvent`）；
/// `ObservableObject` 仅是 `MagicPlayMan` 的内部实现细节，协议不依赖它。
extension MagicPlayMan: PlaybackProviding {
    public var isPlaying: Bool { playing }

    public func play(_ url: URL) async {
        os_log("[AudioDBPlayback] ProviderPlayback.play entered: %{public}s", url.path)
        await play(url, reason: "PlaybackProviding")
        os_log("[AudioDBPlayback] ProviderPlayback.play returned: %{public}s", url.lastPathComponent)
    }

    public func play(_ url: URL, startTime: TimeInterval?) async {
        await play(url, autoPlay: false, startTime: startTime, reason: "PlaybackProviding")
    }

    public func pause() {
        pause(reason: "PlaybackProviding")
    }

    public func toggle() {
        toggle(reason: "PlaybackProviding")
    }

    public func seek(toProgress progress: Double) {
        let normalized = min(max(progress, 0), 1)
        let target = duration > 0 ? duration * normalized : 0
        seek(time: target, reason: "PlaybackProviding")
    }

    public func seek(toTime time: TimeInterval) {
        seek(time: time, reason: "PlaybackProviding")
    }

    public func setPlayMode(_ mode: MagicPlayMode) {
        changePlayMode(mode)
    }

    public func toggleCurrentLike() {
        toggleLike()
    }

    public func reset() async {
        await reset(reason: "PlaybackProviding")
    }

    @discardableResult
    public func addObserver(
        _ callback: @escaping (PlaybackProvidingEvent) -> Void
    ) -> any PlaybackProvidingObserverHandle {
        PlaybackObserver(player: self, callback: callback)
    }
}

@MainActor
private final class PlaybackObserver: PlaybackProvidingObserverHandle {
    private var cancellables: Set<AnyCancellable> = []
    private weak var player: MagicPlayMan?
    private let subscriberID: UUID
    private var cancelled = false

    init(player: MagicPlayMan, callback: @escaping (PlaybackProvidingEvent) -> Void) {
        let center = NotificationCenter.default
        self.player = player
        subscriberID = player.events.addNavigationSubscriber(name: "ProviderPlayback")

        player.events.onStateChanged
            .sink { state in
                os_log("[AudioDBPlayback] ProviderPlayback event.stateChanged: %{public}s", String(describing: state))
                callback(.stateChanged(state))
            }
            .store(in: &cancellables)

        player.events.onCurrentURLChanged
            .sink { url in
                os_log("[AudioDBPlayback] ProviderPlayback event.assetChanged: %{public}s", url?.path ?? "nil")
                callback(.assetChanged(url))
            }
            .store(in: &cancellables)

        player.events.onPlayModeChanged
            .sink { mode in
                callback(.playModeChanged(mode))
            }
            .store(in: &cancellables)

        player.events.onLikeStatusChanged
            .sink { event in
                callback(.likeStatusChanged(asset: event.asset, isLiked: event.isLiked))
                callback(.likedAssetsChanged(player.likedAssets))
            }
            .store(in: &cancellables)

        player.events.onPreviousRequested
            .sink { asset in
                callback(.previousRequested(asset))
            }
            .store(in: &cancellables)

        player.events.onNextRequested
            .sink { asset in
                callback(.nextRequested(asset))
            }
            .store(in: &cancellables)

        player.events.onNavigationFailed
            .sink { failure in
                callback(.navigationFailed(failure))
            }
            .store(in: &cancellables)

        center.publisher(for: .playManTimeUpdate, object: player)
            .compactMap { notification -> (TimeInterval, Double)? in
                guard let currentTime = notification.userInfo?["currentTime"] as? TimeInterval,
                      let progress = notification.userInfo?["progress"] as? Double else {
                    return nil
                }
                return (currentTime, progress)
            }
            .sink { currentTime, progress in
                callback(.timeChanged(currentTime: currentTime, progress: progress))
            }
            .store(in: &cancellables)

        center.publisher(for: .playManDurationChanged, object: player)
            .sink { notification in
                guard let duration = notification.userInfo?["duration"] as? TimeInterval else { return }
                callback(.durationChanged(duration))
            }
            .store(in: &cancellables)
    }

    func cancel() {
        guard !cancelled else { return }
        cancelled = true
        cancellables.removeAll()
        player?.events.removeNavigationSubscriber(id: subscriberID)
        player = nil
    }

}
