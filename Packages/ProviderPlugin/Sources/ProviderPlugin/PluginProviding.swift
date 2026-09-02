import CisumUIComponents
import Foundation
import SwiftUI

/// 插件管理服务能力协议。
///
/// 提供插件的发现、生命周期管理以及 UI 贡献聚合。聚合规则继承自旧版
/// `PluginVM`：场景/海报/状态/标签页/工具栏/主题贡献的收集。当前场景的
/// 管理与持久化已独立到 `SceneProviding`（`kernel.scene`）。
///
/// ## 使用示例
///
/// ```swift
/// let allPlugins = kernel.plugin?.allPlugins ?? []
/// let tabs = kernel.plugin?.getTabViews(reason: "ContentView", demoMode: false) ?? []
/// ```
@MainActor
public protocol PluginProviding: AnyObject, ObservableObject {
    /// 所有已注册的插件。
    var allPlugins: [any SuperPlugin] { get }

    /// 获取所有插件提供的 status 视图。
    func getStatusViews() -> [AnyView]

    /// 获取所有插件提供的 state 视图（与当前场景相关）。
    func getStateViews(currentSceneName: String?) -> [AnyView]

    /// 获取所有场景插件提供的海报视图。
    func getPosterViews() -> [AnyView]

    /// 获取首个引导视图（用于首启引导）。
    func getGuideView() -> AnyView?

    /// 获取所有插件提供的设置视图。
    func getSettingViews() -> [AnyView]

    /// 获取所有插件提供的设置导航项。
    func getSettingNavigationItems() -> [PluginSettingNavigationItem]

    /// 获取所有插件提供的标签页视图。
    ///
    /// - Parameters:
    ///   - reason: 调用原因（通常为调用者类名）。
    ///   - demoMode: 是否处于 Demo 模式。
    /// - Returns: 视图和标签名元组数组。
    func getTabViews(reason: String, demoMode: Bool) -> [(view: AnyView, label: String)]

    /// 用所有插件的 RootView 包裹内容视图。
    @MainActor func wrapWithCurrentRoot<Content: View>(@ViewBuilder content: () -> Content) -> AnyView?

    /// 获取所有插件提供的工具栏按钮。
    func getToolBarButtons() -> [(id: String, view: AnyView)]

    /// 获取所有插件贡献的主题（已重写 sortKey 并去重）。
    func getThemeContributions() -> [LumiUIThemeContribution]

    /// 失效所有缓存的聚合结果。
    func invalidateCaches()
}
