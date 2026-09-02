import CisumUIComponents
import Foundation
import ProviderScene
import Testing
@testable import CisumKernel

// MARK: - 场景测试探针插件

/// 贡献单个场景名的测试探针。
actor SceneProbePlugin: SuperPlugin {
    nonisolated let sceneName: String?

    init(sceneName: String?) {
        self.sceneName = sceneName
    }

    nonisolated static let shared = SceneProbePlugin(sceneName: nil)

    nonisolated var id: String { "SceneProbePlugin.\(sceneName ?? "nil")" }

    @MainActor
    func addSceneItem() -> String? { sceneName }
}

// MARK: - 测试

@MainActor
struct SceneServiceTests {
    /// 清理持久化场景记录，保证测试确定性（与 SceneService 持久化键一致）。
    private func clearPersistedScene() {
        UserDefaults.standard.removeObject(forKey: "currentSceneName")
        UserDefaults.standard.removeObject(forKey: "currentPluginID")
        NSUbiquitousKeyValueStore.default.removeObject(forKey: "currentSceneName")
        NSUbiquitousKeyValueStore.default.removeObject(forKey: "currentPluginID")
    }

    @Test
    func testSceneNamesFromEnabledPlugins() {
        clearPersistedScene()
        let manager = BuiltinPluginManager()
        manager.initializePlugins([
            SceneProbePlugin(sceneName: "音乐库"),
            SceneProbePlugin(sceneName: "有声书"),
        ])
        let service = SceneService(manager: manager, onSceneChanged: {})

        #expect(service.sceneNames == ["音乐库", "有声书"])
        #expect(service.currentSceneName == nil)
    }

    @Test
    func testRestoreFallsBackToFirstScene() {
        clearPersistedScene()
        let manager = BuiltinPluginManager()
        manager.initializePlugins([
            SceneProbePlugin(sceneName: "音乐库"),
            SceneProbePlugin(sceneName: "有声书"),
        ])
        let service = SceneService(manager: manager, onSceneChanged: {})

        service.restoreCurrentScene()
        #expect(service.currentSceneName == "音乐库")
    }

    @Test
    func testRestoreRespectsPersistedScene() {
        clearPersistedScene()
        let manager = BuiltinPluginManager()
        manager.initializePlugins([
            SceneProbePlugin(sceneName: "音乐库"),
            SceneProbePlugin(sceneName: "有声书"),
        ])
        let service = SceneService(manager: manager, onSceneChanged: {})

        // 先持久化「有声书」，再恢复应命中持久化记录。
        UserDefaults.standard.set("有声书", forKey: "currentSceneName")
        service.restoreCurrentScene()
        #expect(service.currentSceneName == "有声书")
    }

    @Test
    func testSetCurrentScenePersistsAndNotifies() throws {
        clearPersistedScene()
        let manager = BuiltinPluginManager()
        manager.initializePlugins([
            SceneProbePlugin(sceneName: "音乐库"),
            SceneProbePlugin(sceneName: "有声书"),
        ])
        var notified = 0
        let service = SceneService(manager: manager, onSceneChanged: { notified += 1 })
        service.restoreCurrentScene()

        try service.setCurrentScene("有声书")
        #expect(service.currentSceneName == "有声书")
        #expect(notified == 1)
        #expect(UserDefaults.standard.string(forKey: "currentSceneName") == "有声书")

        // 重复设置同一场景不重复通知、不重复持久化。
        try service.setCurrentScene("有声书")
        #expect(notified == 1)
    }

    @Test
    func testSetUnknownSceneThrows() {
        clearPersistedScene()
        let manager = BuiltinPluginManager()
        manager.initializePlugins([SceneProbePlugin(sceneName: "音乐库")])
        let service = SceneService(manager: manager, onSceneChanged: {})

        #expect(throws: SceneContributionError.self) {
            try service.setCurrentScene("不存在的场景")
        }
        #expect(service.currentSceneName == nil)
    }

    @Test
    func testPluginLookupBySceneName() {
        clearPersistedScene()
        let manager = BuiltinPluginManager()
        let audio = SceneProbePlugin(sceneName: "音乐库")
        let book = SceneProbePlugin(sceneName: "有声书")
        manager.initializePlugins([audio, book])
        let service = SceneService(manager: manager, onSceneChanged: {})

        #expect(service.plugin(for: "音乐库") != nil)
        #expect(service.plugin(for: "有声书") != nil)
        #expect(service.plugin(for: "不存在") == nil)
    }
}
