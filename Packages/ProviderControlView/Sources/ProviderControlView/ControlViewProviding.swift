import SwiftUI

@MainActor
public enum ControlViewProvidingEvent {
    case viewInvalidated
}

@MainActor
public protocol ControlViewProvidingObserverHandle: AnyObject {
    func cancel()
}

/// 播放控制区提供能力协议（对齐 Lumi 各区域独立 Provider 的范式）。
///
/// 定义「内核 → 根布局顶部播放控制区」这一段的最小契约：宿主在装配时
/// 通过内核解析 `ControlViewProviding`，拿到播放控制视图后注入根布局。
/// 该区域是根视图中的一小块，独立成 Provider 便于替换与解耦。
@MainActor
public protocol ControlViewProviding: AnyObject, ObservableObject {
    /// 返回顶部播放控制区视图。
    func makeControlView() -> AnyView

    @discardableResult
    func addObserver(_ callback: @escaping (ControlViewProvidingEvent) -> Void) -> any ControlViewProvidingObserverHandle
}

public extension ControlViewProviding {
    @discardableResult
    func addObserver(_ callback: @escaping (ControlViewProvidingEvent) -> Void) -> any ControlViewProvidingObserverHandle {
        NoopControlViewProvidingObserverHandle()
    }
}

@MainActor
public final class NoopControlViewProvidingObserverHandle: ControlViewProvidingObserverHandle {
    public init() {}
    public func cancel() {}
}
