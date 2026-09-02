import Combine
import SwiftUI

/// 根视图提供能力协议（对齐 Lumi `ProviderRootView/RootViewProviding`）。
///
/// 定义「内核 → 应用根布局视图」这一段的最小契约：宿主在启动时通过内核
/// 解析 `RootViewProviding`，拿到根布局视图后作为窗口内容展示。
///
/// 根布局对应 Cisum 的 AppLayoutView 结构：
/// - 顶部播放控制区（通过 `setControlView(_:)` 注入）；
/// - 内容区（通过 `setContentView(_:)` 注入，通常来自 `ContentViewProviding`）；
/// - 底部状态区（通过 `setStatusView(_:)` 注入）；
/// - 工具栏内容（通过 `setToolbarContent(_:)` 注入，通常来自 `ToolbarProviding`）。
///
/// 协议只声明能力，不关心具体实现。使用 `AnyView` 而非 `associatedtype`：
/// 协议可无泛型约束地作为存在类型（`any RootViewProviding`）注册进
/// `CisumKernel` 的 Provider 注册表。
@MainActor
public protocol RootViewProviding: AnyObject, ObservableObject {
    /// 注入顶部播放控制区视图（传 `nil` 表示使用默认实现）。
    func setControlView(_ view: AnyView?)

    /// 注入主内容区视图（传 `nil` 表示回退到占位）。
    ///
    /// 宿主通常把 `ContentViewProviding.makeContentView()` 的结果注入进来。
    func setContentView(_ view: AnyView?)

    /// 注入底部状态区视图（传 `nil` 表示使用默认实现）。
    func setStatusView(_ view: AnyView?)

    /// 注入工具栏内容（传 `nil` 表示使用默认实现，如场景切换器）。
    ///
    /// 宿主通常把 `ToolbarProviding.makeToolbarView()` 的结果注入进来。
    func setToolbarContent(_ view: AnyView?)

    /// 返回根布局视图（控制区 + 内容区 + 状态区 + 工具栏）。
    func makeRootView() -> AnyView
}

public extension RootViewProviding {
    func setControlView(_ view: AnyView?) {}
    func setContentView(_ view: AnyView?) {}
    func setStatusView(_ view: AnyView?) {}
    func setToolbarContent(_ view: AnyView?) {}
}
