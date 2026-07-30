import CisumUI
import Foundation
import SwiftUI

/// 插件管理服务能力协议。
///
/// 提供插件的发现、注册、生命周期管理以及 UI 贡献聚合。
///
/// ## 使用示例
///
/// ```swift
/// let allPlugins = kernel.plugin?.allPlugins ?? []
/// let sceneNames = kernel.plugin?.sceneNames ?? []
/// ```
@MainActor
public protocol PluginProviding: AnyObject, ObservableObject {
    /// 所有已注册的插件。
    var allPlugins: [any SuperPlugin] { get }

    /// 所有可用场景名称（由提供场景的插件贡献）。
    var sceneNames: [String] { get }

    /// 当前激活的场景名称。
    var currentSceneName: String? { get }

    /// 切换当前激活的场景。
    ///
    /// - Parameter sceneName: 目标场景名称。
    func setCurrentScene(_ sceneName: String) throws

    /// 获取所有插件提供的状态视图。
    func getStatusViews() -> [AnyView]

    /// 获取所有插件提供的标签页视图。
    ///
    /// - Parameters:
    ///   - reason: 调用原因（通常为调用者类名）。
    ///   - demoMode: 是否处于 Demo 模式。
    /// - Returns: 视图和标签名元组数组。
    func getTabViews(reason: String, demoMode: Bool) -> [(view: AnyView, label: String)]

    /// 用所有插件的 RootView 包裹内容视图。
    ///
    /// - Parameter content: 原始内容视图。
    /// - Returns: 包裹后的视图。
    @MainActor func wrapWithCurrentRoot<Content: View>(@ViewBuilder content: () -> Content) -> AnyView?

    /// 获取所有插件提供的工具栏按钮。
    func getToolBarButtons() -> [(id: String, view: AnyView)]

    /// 获取所有插件贡献的主题。
    func getThemeContributions() -> [LumiUIThemeContribution]

    /// 根据场景名称查找对应插件。
    ///
    /// - Parameter sceneName: 场景名称。
    /// - Returns: 提供该场景的插件实例。
    func plugin(for sceneName: String) -> (any SuperPlugin)?
}
