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
}
