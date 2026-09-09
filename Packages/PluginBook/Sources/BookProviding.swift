import Foundation

/// 书籍库发生外部变化时，Provider 实现通过此事件通知消费者。
@MainActor
public enum BookProvidingEvent {
    case libraryChanged(totalCount: Int)
}

@MainActor
public protocol BookProvidingObserverHandle: AnyObject {
    func cancel()
}

/// 书籍库的跨插件读取边界。
///
/// 具体数据库、同步实现和 UI 生命周期属于书籍插件；其他插件只依赖此协议，
/// 通过 Observer 接收变化，不直接导入 `PluginBook`。
@MainActor
public protocol BookProviding: AnyObject {
    var bookDisk: URL? { get }
    var isAvailable: Bool { get }
    func totalCount() async -> Int

    @discardableResult
    func addObserver(
        _ callback: @escaping (BookProvidingEvent) -> Void
    ) -> any BookProvidingObserverHandle
}

@MainActor
public final class NoopBookProvidingObserverHandle: BookProvidingObserverHandle {
    public init() {}
    public func cancel() {}
}

public extension BookProviding {
    @discardableResult
    func addObserver(
        _ callback: @escaping (BookProvidingEvent) -> Void
    ) -> any BookProvidingObserverHandle {
        NoopBookProvidingObserverHandle()
    }
}
