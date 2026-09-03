import CisumUIComponents
import SwiftUI

public enum PluginPolicy: String, Sendable, Codable {
    case alwaysOn
    case optOut
    case optIn
    case disabled

    public var shouldRegister: Bool {
        self != .disabled
    }

    public var allowUserToggle: Bool {
        switch self {
        case .alwaysOn, .disabled:
            false
        case .optOut, .optIn:
            true
        }
    }

    public var defaultEnabled: Bool {
        switch self {
        case .alwaysOn, .optOut:
            true
        case .optIn, .disabled:
            false
        }
    }
}

public struct PluginMetadata: Equatable, Sendable {
    public let id: String
    public let displayName: String
    public let description: String
    public let iconName: String
    public let order: Int
    public let policy: PluginPolicy

    public var shouldRegister: Bool {
        policy.shouldRegister
    }

    public init(
        id: String = "",
        displayName: String,
        description: String,
        iconName: String = "puzzlepiece.extension",
        order: Int = 9999,
        policy: PluginPolicy = .alwaysOn
    ) {
        self.id = id
        self.displayName = displayName
        self.description = description
        self.iconName = iconName
        self.order = order
        self.policy = policy
    }
}

public struct PluginSettingNavigationItem: Identifiable {
    public let id: String
    public let title: String
    public let description: String?
    public let iconName: String
    public let order: Int
    public let destination: AnyView

    public init(
        id: String,
        title: String,
        description: String? = nil,
        iconName: String,
        order: Int,
        destination: AnyView
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.iconName = iconName
        self.order = order
        self.destination = destination
    }
}

public protocol SuperPlugin: Actor {
    static var shared: Self { get }
    static var metadata: PluginMetadata { get }

    nonisolated var id: String { get }
    nonisolated var label: String { get }
    nonisolated var title: String { get }
    nonisolated var description: String { get }
    nonisolated var iconName: String { get }

    static var order: Int { get }
    static var shouldRegister: Bool { get }

    @MainActor func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View
    @MainActor func addGuideView() -> AnyView?
    @MainActor func completeGuidePage() -> Bool
    @MainActor func addStateView() -> AnyView?
    @MainActor func addPosterView() -> AnyView?
    @MainActor func addTabView(reason: String, demoMode: Bool) -> (view: AnyView, label: String)?
    @MainActor func addSettingView() -> AnyView?
    @MainActor func addSettingNavigationItem() -> PluginSettingNavigationItem?
    @MainActor func addStatusView() -> AnyView?
    @MainActor func addToolBarButtons() -> [(id: String, view: AnyView)]
    @MainActor func addThemeContributions() -> [LumiUIThemeContribution]

    /// 注册阶段：插件可向 Kernel 注册 Provider 或共享目录贡献。
    @MainActor func onRegister(kernel: CisumKernelContainer) async throws
    /// 启动阶段：所有已注册 Provider 可被插件使用。
    @MainActor func onBoot(kernel: CisumKernelContainer) async throws
    /// 就绪阶段：全部插件完成 Boot 后执行依赖初始化。
    @MainActor func onReady(kernel: CisumKernelContainer) async throws
    /// 停止阶段：撤回运行期 Provider、监听器和外部资源。
    @MainActor func onShutdown(kernel: CisumKernelContainer) async throws
    /// 注销阶段：撤回注册阶段的目录型贡献。
    @MainActor func onUnregister(kernel: CisumKernelContainer) async throws

    /// 运行时启用：恢复被禁用时停止的监听器与外部资源。
    @MainActor func onEnable(kernel: CisumKernelContainer) async throws
    /// 运行时禁用：停止监听器与外部资源。
    @MainActor func onDisable(kernel: CisumKernelContainer) async throws
}

public extension SuperPlugin {
    static var metadata: PluginMetadata {
        PluginMetadata(
            id: String(describing: Self.self),
            displayName: String(describing: Self.self),
            description: "",
            order: 9999,
            policy: .alwaysOn
        )
    }

    nonisolated var id: String {
        let metadataId = Self.metadata.id
        return metadataId.isEmpty ? String(describing: Self.self) : metadataId
    }
    nonisolated var label: String { id }
    nonisolated var title: String { Self.metadata.displayName }
    nonisolated var description: String { Self.metadata.description }
    nonisolated var iconName: String { Self.metadata.iconName }
    static var order: Int { metadata.order }
    static var shouldRegister: Bool { metadata.shouldRegister }

    nonisolated func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View { nil }
    nonisolated func addGuideView() -> AnyView? { nil }
    nonisolated func completeGuidePage() -> Bool { true }
    nonisolated func addStateView() -> AnyView? { nil }
    nonisolated func addPosterView() -> AnyView? { nil }
    @MainActor func addTabView(reason: String, demoMode: Bool = false) -> (view: AnyView, label: String)? { nil }
    nonisolated func addSettingView() -> AnyView? { nil }
    nonisolated func addSettingNavigationItem() -> PluginSettingNavigationItem? { nil }
    nonisolated func addStatusView() -> AnyView? { nil }
    nonisolated func addToolBarButtons() -> [(id: String, view: AnyView)] { [] }
    @MainActor func addThemeContributions() -> [LumiUIThemeContribution] { [] }

    @MainActor func onRegister(kernel: CisumKernelContainer) async throws {}
    @MainActor func onBoot(kernel: CisumKernelContainer) async throws {}
    @MainActor func onReady(kernel: CisumKernelContainer) async throws {}
    @MainActor func onShutdown(kernel: CisumKernelContainer) async throws {}
    @MainActor func onUnregister(kernel: CisumKernelContainer) async throws {}
    @MainActor func onEnable(kernel: CisumKernelContainer) async throws {}
    @MainActor func onDisable(kernel: CisumKernelContainer) async throws {}
}

public extension SuperPlugin {
    @MainActor
    func provideRootView(_ content: AnyView) -> AnyView? {
        addRootView { content }
    }

    @MainActor
    func wrapRoot(_ content: AnyView) -> AnyView {
        provideRootView(content) ?? content
    }
}
