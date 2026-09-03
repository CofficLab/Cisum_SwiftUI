import Combine
import Foundation
import MagicPlayMan

/// 将 `MagicPlayMan` 桥接为内核的 `PlaybackProviding`。
///
/// 此一致性声明在 `FactoryCisum` 中（而非 `MagicPlayMan` 包内），以避免
/// `MagicPlayMan → CisumKernel → MagicPlayMan` 的循环依赖。`MagicPlayMan`
/// 已经是 `@MainActor ObservableObject`，其 `@Published` 状态（`state`、
/// `currentURL`、`currentTime`、`duration`、`progress`、`playMode`、`likedAssets`）
/// 与 `hasAsset`、`next()`、`previous()`、`togglePlayMode()` 直接满足协议要求；
/// 这里只补齐少数签名不同的传输控制方法，内部调用 `MagicPlayMan` 真实 API
/// （`reason` 日志标签使用本桥接的固定标识）。
extension MagicPlayMan: PlaybackProviding {
    public var isPlaying: Bool { playing }

    public func play(_ url: URL) async {
        await play(url, reason: "PlaybackProviding")
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
    private var cancelled = false

    init(player: MagicPlayMan, callback: @escaping (PlaybackProvidingEvent) -> Void) {
        let center = NotificationCenter.default

        center.publisher(for: .playManStateChanged, object: player)
            .sink { [weak player] _ in
                guard let player else { return }
                callback(.stateChanged(player.state))
            }
            .store(in: &cancellables)

        center.publisher(for: .playManAssetChanged, object: player)
            .sink { notification in
                callback(.assetChanged(notification.userInfo?["asset"] as? URL))
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
    }

}
