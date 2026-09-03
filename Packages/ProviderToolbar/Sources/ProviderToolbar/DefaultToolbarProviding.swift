import KernelCore
import SwiftUI

/// 默认 `ToolbarProviding` 实现：渲染场景切换器（迁移自 FactoryCisum `SceneSwitcher`）。
///
/// 场景切换器列出内置固定场景（如「音乐库」「有声书」），选择后切换
/// `currentScene`，从而改变内容区展示的 Tab。
@MainActor
public final class DefaultToolbarProviding: ToolbarProviding, ObservableObject {
    private let kernel: CisumKernel
    private let eventObservers = KernelEventObserverStore<ToolbarProvidingEvent>()

    public init(kernel: CisumKernel) {
        self.kernel = kernel
    }

    public func makeToolbarView() -> AnyView {
        AnyView(SceneSwitcher(kernel: kernel))
    }

    @discardableResult
    public func addObserver(
        _ callback: @escaping (ToolbarProvidingEvent) -> Void
    ) -> any ToolbarProvidingObserverHandle {
        eventObservers.add(callback)
    }
}

extension KernelEventObserverHandle: ToolbarProvidingObserverHandle {}
