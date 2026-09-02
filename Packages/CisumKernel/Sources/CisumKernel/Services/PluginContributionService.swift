import CisumUIComponents
import Foundation
import ProviderPlugin
import SwiftUI

/// 将 `BuiltinPluginManager` 中的插件 UI 贡献聚合为 Kernel Provider。
///
/// 该服务复用旧版 `PluginVM` 的贡献规则（场景/海报/状态/标签页/工具栏/主题
/// 贡献的收集、主题 sortKey 重写与去重、当前场景持久化与缓存失效），
/// 但把插件发现与视图消费边界放到 Kernel，使 Factory 与具体 App 布局
/// 无需直接依赖插件注册表。
@MainActor
public final class PluginContributionService: ObservableObject, PluginProviding {
    private let manager: BuiltinPluginManager

    @Published public private(set) var currentSceneName: String?

    // MARK: - Persistence Keys（与旧版 PluginRepo 一致，保证向后兼容）

    private static let sceneKey = "currentSceneName"
    private static let pluginIDKey = "currentPluginID"

    // MARK: - Caches

    private var cachedStatusViews: [AnyView]?
    private var cachedPosterViews: [AnyView]?
    private var cachedSettingViews: [AnyView]?
    private var cachedSettingNavItems: [PluginSettingNavigationItem]?
    private var cachedToolBarButtons: [(id: String, view: AnyView)]?
    private var cachedThemeContributions: [LumiUIThemeContribution]?

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
        guard currentSceneName != sceneName else { return }
        currentSceneName = sceneName
        persistScene(sceneName)
        invalidateCaches()
    }

    /// 从持久化恢复当前场景；无记录或记录失效时回落到首个场景。
    public func restoreCurrentScene() {
        let names = sceneNames
        guard !names.isEmpty else {
            currentSceneName = nil
            return
        }

        let saved = UserDefaults.standard.string(forKey: Self.sceneKey)
            ?? NSUbiquitousKeyValueStore.default.string(forKey: Self.sceneKey)
        if let saved, names.contains(saved) {
            currentSceneName = saved
        } else {
            let first = names[0]
            currentSceneName = first
            persistScene(first)
        }
    }

    public func getStatusViews() -> [AnyView] {
        if let cachedStatusViews { return cachedStatusViews }
        let value = manager.enabledPlugins.compactMap { $0.addStatusView() }
        cachedStatusViews = value
        return value
    }

    public func getStateViews(currentSceneName: String?) -> [AnyView] {
        manager.enabledPlugins.compactMap { $0.addStateView(currentSceneName: currentSceneName) }
    }

    public func getPosterViews() -> [AnyView] {
        if let cachedPosterViews { return cachedPosterViews }
        let value = manager.enabledPlugins.compactMap { $0.addPosterView() }
        cachedPosterViews = value
        return value
    }

    public func getGuideView() -> AnyView? {
        for plugin in manager.enabledPlugins {
            if let view = plugin.addGuideView() { return view }
        }
        return nil
    }

    public func getSettingViews() -> [AnyView] {
        if let cachedSettingViews { return cachedSettingViews }
        let value = manager.enabledPlugins.compactMap { $0.addSettingView() }
        cachedSettingViews = value
        return value
    }

    public func getSettingNavigationItems() -> [PluginSettingNavigationItem] {
        if let cachedSettingNavItems { return cachedSettingNavItems }
        // 对齐 Lumi `SettingEntryItem.order` 语义：按导航项自身 order 排序，
        // 允许插件在导航项中指定独立顺序（如「外观」紧跟「通用」排第 2）。
        let value = manager.enabledPlugins
            .compactMap { $0.addSettingNavigationItem() }
            .sorted { $0.order < $1.order }
        cachedSettingNavItems = value
        return value
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
        if let cachedToolBarButtons { return cachedToolBarButtons }
        let value = manager.enabledPlugins.flatMap { $0.addToolBarButtons() }
        cachedToolBarButtons = value
        return value
    }

    /// 聚合所有主题贡献，按插件 `order` 重写 `sortKey`，按 `id` 去重并排序。
    ///
    /// 与旧版 `PluginVM.getThemeContributions()` 行为一致。
    public func getThemeContributions() -> [LumiUIThemeContribution] {
        if let cachedThemeContributions { return cachedThemeContributions }

        var seen = Set<String>()
        let value: [LumiUIThemeContribution] = manager.enabledPlugins
            .sorted { type(of: $0).metadata.order < type(of: $1).metadata.order }
            .flatMap { plugin -> [LumiUIThemeContribution] in
                let order = type(of: plugin).metadata.order
                return plugin.addThemeContributions().compactMap { contribution in
                    guard seen.insert(contribution.id).inserted else { return nil }
                    return LumiUIThemeContribution(
                        sortKey: ThemeSortKey(pluginOrder: order, themeId: contribution.id),
                        chromeTheme: contribution.chromeTheme,
                        editorThemeId: contribution.id,
                        uiTheme: contribution.uiTheme
                    )
                }
            }

        cachedThemeContributions = value
        return value
    }

    public func plugin(for sceneName: String) -> (any SuperPlugin)? {
        manager.enabledPlugins.first { $0.addSceneItem() == sceneName }
    }

    public func invalidateCaches() {
        cachedStatusViews = nil
        cachedPosterViews = nil
        cachedSettingViews = nil
        cachedSettingNavItems = nil
        cachedToolBarButtons = nil
        cachedThemeContributions = nil
        objectWillChange.send()
    }

    // MARK: - Persistence

    private func persistScene(_ sceneName: String) {
        UserDefaults.standard.set(sceneName, forKey: Self.sceneKey)
        NSUbiquitousKeyValueStore.default.set(sceneName, forKey: Self.sceneKey)
        NSUbiquitousKeyValueStore.default.synchronize()

        if let plugin = plugin(for: sceneName) {
            let pluginID = plugin.id
            UserDefaults.standard.set(pluginID, forKey: Self.pluginIDKey)
            NSUbiquitousKeyValueStore.default.set(pluginID, forKey: Self.pluginIDKey)
            NSUbiquitousKeyValueStore.default.synchronize()
        }
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
