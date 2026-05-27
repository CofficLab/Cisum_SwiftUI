import CisumUI
import OSLog
import SwiftUI

/// `SuperPlugin` 是 Cisum 应用的插件系统核心协议。
/// 所有插件必须实现此协议以便集成到应用程序中。
///
/// 该协议定义了插件的基本属性和行为，包括：
/// - 插件的标识和显示信息
/// - 插件在不同界面区域的视图渲染方法
/// - 插件的生命周期管理方法
///
/// ## 插件生命周期
///
/// 1. **注册阶段**: 插件被自动发现并实例化，调用 `onRegister()`
/// 2. **启用阶段**: 插件被添加到 UI 树，调用 `onEnable()`
/// 3. **禁用阶段**: 插件从 UI 树移除，调用 `onDisable()`
///
/// ## 使用示例
///
/// ```swift
/// actor MyPlugin: SuperPlugin {
///     static let shared = MyPlugin()
///
///     static var shouldRegister: Bool { true }
///     static var order: Int { 100 }
///
///     let title = "我的插件"
///     let description = "插件描述"
///     let iconName = "star.fill"
///
///     nonisolated func onRegister() {
///         // 初始化操作
///     }
/// }
/// ```
protocol SuperPlugin: Actor {
    // MARK: - Shared Instance

    /// 插件共享实例。
    ///
    /// PluginProvider 的自动发现阶段通过类型暴露的共享实例拿到插件，
    /// 避免使用 ObjC Runtime 的 `alloc/init` 创建 Actor 实例，
    /// 确保 Actor 初始化语义的正确性。
    static var shared: Self { get }

    // MARK: - Basic Properties

    /// 插件的唯一标识符
    nonisolated var id: String { get }

    /// 插件的标签（用于显示和标识）
    nonisolated var label: String { get }

    /// 插件的标题
    nonisolated var title: String { get }

    /// 插件的描述
    nonisolated var description: String { get }

    /// 插件的图标名称
    nonisolated var iconName: String { get }

    /// 返回插件的场景名称，如果插件提供场景则返回场景名称，否则返回 nil

    @MainActor func addSceneItem() -> String?

    /// 插件注册顺序，数字越小越先注册
    static var order: Int { get }

    /// 插件是否应该注册到系统中
    /// 开发者可通过此属性控制插件是否启用
    static var shouldRegister: Bool { get }

    // MARK: - View Methods

    /// 添加根视图包裹
    @MainActor func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View

    /// 添加引导视图
    @MainActor func addGuideView() -> AnyView?

    /// 添加弹窗视图
    @MainActor func addSheetView(storage: StorageLocation?) -> AnyView?

    /// 添加状态视图
    @MainActor func addStateView(currentSceneName: String?) -> AnyView?

    /// 添加海报视图
    @MainActor func addPosterView() -> AnyView?

    /// 添加标签页视图
    @MainActor func addTabView(reason: String, currentSceneName: String?, demoMode: Bool) -> (view: AnyView, label: String)?

    /// 添加设置视图
    @MainActor func addSettingView() -> AnyView?

    /// 添加状态栏视图
    @MainActor func addStatusView() -> AnyView?

    /// 添加工具栏按钮
    @MainActor func addToolBarButtons() -> [(id: String, view: AnyView)]

    /// 添加主题贡献
    @MainActor func addThemeContributions() -> [LumiUIThemeContribution]

    // MARK: - Lifecycle Methods

    /// 插件注册完成后的回调
    ///
    /// 在插件成功注册到 PluginProvider 后调用。
    /// 用于执行初始化操作，如加载配置、注册监听器等。
    ///
    /// ## 使用示例
    /// ```swift
    /// actor MyPlugin: SuperPlugin {
    ///     nonisolated func onRegister() {
    ///         Task {
    ///             // 初始化操作
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// ## 注意事项
    /// - 此方法不在主线程上执行（使用 `nonisolated`）
    /// - 适合执行轻量级初始化和启动异步任务
    /// - 如果需要访问 actor 隔离状态，请使用 `Task { await ... }`
    /// - 不要在此方法中执行阻塞操作
    nonisolated func onRegister()

    /// 插件被启用时的回调
    ///
    /// 当插件注册完成且满足启用条件后调用。
    /// 此时插件将开始参与 UI 渲染和交互。
    /// 适合执行：
    /// - 启动后台任务
    /// - 连接外部服务
    /// - 更新 UI 状态
    nonisolated func onEnable()

    /// 插件被禁用时的回调
    ///
    /// 当插件从启用状态变为禁用状态时调用。
    /// 此时插件将停止参与 UI 渲染和交互。
    /// 适合执行：
    /// - 停止后台任务
    /// - 断开外部连接
    /// - 保存状态
    nonisolated func onDisable()
}

// MARK: - Default Implementations

extension SuperPlugin {
    // MARK: - Basic Properties Defaults

    nonisolated var id: String { self.label }

    nonisolated var label: String { String(describing: type(of: self)) }

    nonisolated var title: String { self.label }

    /// 默认的场景项实现，返回 nil 表示不提供场景
    @MainActor func addSceneItem() -> String? { nil }

    /// 默认的注册顺序实现
    static var order: Int { 9999 }

    /// 默认的注册控制，默认注册
    static var shouldRegister: Bool { true }

    // MARK: - View Methods Defaults

    nonisolated func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View { nil }

    nonisolated func addGuideView() -> AnyView? { nil }

    nonisolated func addSheetView(storage: StorageLocation?) -> AnyView? { nil }

    nonisolated func addStateView(currentSceneName: String?) -> AnyView? { nil }

    @MainActor func addTabView(reason: String, currentSceneName: String?, demoMode: Bool = false) -> (view: AnyView, label: String)? { nil }

    nonisolated func addPosterView() -> AnyView? { nil }

    nonisolated func addToolBarButtons() -> [(id: String, view: AnyView)] { [] }

    nonisolated func addStatusView() -> AnyView? { nil }

    nonisolated func addSettingView() -> AnyView? { nil }

    @MainActor func addThemeContributions() -> [LumiUIThemeContribution] { [] }

    // MARK: - Lifecycle Defaults

    /// 默认的注册回调实现
    ///
    /// 默认不做任何事，子插件可以重写此方法以自定义注册后的行为。
    nonisolated func onRegister() {}

    /// 默认的启用回调实现
    ///
    /// 默认不做任何事，子插件可以重写此方法以自定义启用后的行为。
    nonisolated func onEnable() {}

    /// 默认的禁用回调实现
    ///
    /// 默认不做任何事，子插件可以重写此方法以自定义禁用后的行为。
    nonisolated func onDisable() {}
}

// MARK: - Convenience

extension SuperPlugin {
    @MainActor
    func provideRootView(_ content: AnyView) -> AnyView? {
        self.addRootView { content }
    }

    @MainActor
    func wrapRoot(_ content: AnyView) -> AnyView {
        if let wrapped = self.provideRootView(content) {
            return wrapped
        }
        return content
    }
}

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}
