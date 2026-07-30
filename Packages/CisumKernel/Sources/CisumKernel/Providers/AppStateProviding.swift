import Foundation

/// 应用状态服务能力协议。
///
/// 提供应用级的 UI 状态管理，包括 Demo 模式、数据库视图显隐、
/// 导入/拖放状态等。
///
/// ## 使用示例
///
/// ```swift
/// kernel.appState?.enterDemoMode()
/// let isDemo = kernel.appState?.isDemoMode ?? false
/// ```
@MainActor
public protocol AppStateProviding: AnyObject, ObservableObject {
    /// 是否处于 Demo 模式。
    var isDemoMode: Bool { get }

    /// 数据库视图是否可见。
    var isDBViewVisible: Bool { get }

    /// 是否正在进行导入操作。
    var isImporting: Bool { get }

    /// 是否有正在进行中的拖放操作。
    var hasDragOperation: Bool { get }

    /// 进入 Demo 模式。
    func enterDemoMode()

    /// 退出 Demo 模式。
    func exitDemoMode()

    /// 显示数据库视图。
    func showDBView()

    /// 隐藏数据库视图。
    func hideDBView()

    /// 更新导入状态。
    func setImporting(_ importing: Bool)
}
