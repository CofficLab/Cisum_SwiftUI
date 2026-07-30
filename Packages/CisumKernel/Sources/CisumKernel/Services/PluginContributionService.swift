import CisumUI
import Foundation
import SwiftUI

/// 将 `BuiltinPluginManager` 中的插件 UI 贡献聚合为 Kernel Provider。
///
/// 该服务复用旧版 `PluginVM` 的贡献规则，但把插件发现和视图消费边界
/// 放到 Kernel，使 Factory 和具体 App 布局无需直接依赖插件注册表。
@MainActor
public final class PluginContributionService: ObservableObject, PluginProviding {
    private let manager: BuiltinPluginManager

    @Published public private(set) var currentSceneName: String?

    public init(manager: BuiltinPluginManager) {
        self.manager = manager
        self.currentSceneName = nil
    }

    public var allPlugins: [any SuperPlugin] {
        manager.allPlugins
    }

    public var sceneNames: [String] {
        manager.enabledPlugins.compactMap { $0.addSceneItem() }
    }

    public func setCurrentScene(_ sceneName: String) throws {
        guard sceneNames.contains(sceneName) else {
            throw PluginContributionError.unknownScene(sceneName)
        }
        currentSceneName = sceneName
    }

    public func getStatusViews() -> [AnyView] {
        manager.enabledPlugins.compactMap { $0.addStatusView() }
    }

    public func getTabViews(reason: String, demoMode: Bool) -> [(view: AnyView, label: String)] {
        manager.enabledPlugins.compactMap { plugin in
            plugin.addTabView(
                reason: reason,
                currentSceneName: currentSceneName,
                demoMode: demoMode
            )
        }
    }

    public func wrapWithCurrentRoot<Content: View>(@ViewBuilder content: () -> Content) -> AnyView? {
        var wrapped = AnyView(content())

        for plugin in manager.enabledPlugins {
            wrapped = plugin.wrapRoot(wrapped)
        }

        return wrapped
    }

    public func getToolBarButtons() -> [(id: String, view: AnyView)] {
        manager.enabledPlugins.flatMap { $0.addToolBarButtons() }
    }

    public func getThemeContributions() -> [LumiUIThemeContribution] {
        manager.enabledPlugins
            .sorted { type(of: $0).order < type(of: $1).order }
            .flatMap { $0.addThemeContributions() }
    }

    public func plugin(for sceneName: String) -> (any SuperPlugin)? {
        manager.enabledPlugins.first { $0.addSceneItem() == sceneName }
    }
}

public enum PluginContributionError: LocalizedError {
    case unknownScene(String)

    public var errorDescription: String? {
        switch self {
        case let .unknownScene(sceneName):
            "Unknown scene: \(sceneName)"
        }
    }
}
