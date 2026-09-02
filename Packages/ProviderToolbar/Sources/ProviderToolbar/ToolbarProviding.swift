import Combine
import SwiftUI

/// 工具栏视图提供能力协议（对齐 Lumi `ProviderToolbar/ToolbarProviding`）。
///
/// 定义「内核 → 窗口工具栏」这一段的最小契约：宿主在启动时解析
/// `ToolbarProviding`，把工具栏视图注入 `RootViewProviding`（场景切换器等）。
///
/// 使用 `AnyView` 而非 `associatedtype`：协议可无泛型约束地作为存在类型
/// （`any ToolbarProviding`）注册进 `CisumKernel` 的 Provider 注册表。
@MainActor
public protocol ToolbarProviding: AnyObject, ObservableObject {
    /// 返回工具栏视图（如场景切换器）。
    func makeToolbarView() -> AnyView
}
