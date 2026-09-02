import CisumUIComponents
import Foundation
import ProviderScene
import SwiftUI

/// `SceneProviding` 的具体实现。
///
/// 场景由插件通过 `SuperPlugin.addSceneItem()` 贡献。本服务统一负责场景管理：
/// - 场景列表发现（从已启用插件收集）
/// - 当前场景状态与持久化（`UserDefaults` + `NSUbiquitousKeyValueStore`，
///   持久化键与旧版 `PluginRepo` 保持一致，保证向后兼容）
/// - 场景切换后的依赖失效（通过注入的 `onSceneChanged` 回调通知插件贡献服务
///   重建视图缓存）
///
/// 对齐 Lumi `ProviderScene/SceneProviding`：协议定义能力契约，实现在 Kernel 侧
/// 聚合插件贡献。
@MainActor
public final class SceneService: ObservableObject, SceneProviding {
    // MARK: - Persistence Keys（与旧版 PluginRepo 一致，保证向后兼容）

    private static let sceneKey = "currentSceneName"
    private static let pluginIDKey = "currentPluginID"

    private let manager: BuiltinPluginManager
    private let onSceneChanged: () -> Void

    @Published public private(set) var currentSceneName: String?

    public init(
        manager: BuiltinPluginManager,
        onSceneChanged: @escaping () -> Void
    ) {
        self.manager = manager
        self.onSceneChanged = onSceneChanged
        self.currentSceneName = nil
    }

    public var sceneNames: [String] {
        manager.enabledPlugins.compactMap { $0.addSceneItem() }
    }

    public func setCurrentScene(_ sceneName: String) throws {
        guard sceneNames.contains(sceneName) else {
            throw SceneContributionError.unknownScene(sceneName)
        }
        guard currentSceneName != sceneName else { return }
        currentSceneName = sceneName
        persistScene(sceneName)
        onSceneChanged()
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

    public func plugin(for sceneName: String) -> (any SuperPlugin)? {
        manager.enabledPlugins.first { $0.addSceneItem() == sceneName }
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

public enum SceneContributionError: LocalizedError {
    case unknownScene(String)

    public var errorDescription: String? {
        switch self {
        case let .unknownScene(sceneName):
            "Unknown scene: \(sceneName)"
        }
    }
}
