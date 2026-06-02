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
        id: String,
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

    @MainActor func addSceneItem() -> String?
    @MainActor func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View
    @MainActor func addGuideView() -> AnyView?
    @MainActor func completeGuidePage() -> Bool
    @MainActor func addStateView(currentSceneName: String?) -> AnyView?
    @MainActor func addPosterView() -> AnyView?
    @MainActor func addTabView(reason: String, currentSceneName: String?, demoMode: Bool) -> (view: AnyView, label: String)?
    @MainActor func addSettingView() -> AnyView?
    @MainActor func addSettingNavigationItem() -> PluginSettingNavigationItem?
    @MainActor func addStatusView() -> AnyView?
    @MainActor func addToolBarButtons() -> [(id: String, view: AnyView)]
    @MainActor func addThemeContributions() -> [LumiUIThemeContribution]

    nonisolated func onRegister()
    nonisolated func onEnable()
    nonisolated func onDisable()
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

    nonisolated var id: String { Self.metadata.id }
    nonisolated var label: String { Self.metadata.id }
    nonisolated var title: String { Self.metadata.displayName }
    nonisolated var description: String { Self.metadata.description }
    nonisolated var iconName: String { Self.metadata.iconName }
    static var order: Int { metadata.order }
    static var shouldRegister: Bool { metadata.shouldRegister }

    @MainActor func addSceneItem() -> String? { nil }
    nonisolated func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View { nil }
    nonisolated func addGuideView() -> AnyView? { nil }
    nonisolated func completeGuidePage() -> Bool { true }
    nonisolated func addStateView(currentSceneName: String?) -> AnyView? { nil }
    nonisolated func addPosterView() -> AnyView? { nil }
    @MainActor func addTabView(reason: String, currentSceneName: String?, demoMode: Bool = false) -> (view: AnyView, label: String)? { nil }
    nonisolated func addSettingView() -> AnyView? { nil }
    nonisolated func addSettingNavigationItem() -> PluginSettingNavigationItem? { nil }
    nonisolated func addStatusView() -> AnyView? { nil }
    nonisolated func addToolBarButtons() -> [(id: String, view: AnyView)] { [] }
    @MainActor func addThemeContributions() -> [LumiUIThemeContribution] { [] }

    nonisolated func onRegister() {}
    nonisolated func onEnable() {}
    nonisolated func onDisable() {}
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
