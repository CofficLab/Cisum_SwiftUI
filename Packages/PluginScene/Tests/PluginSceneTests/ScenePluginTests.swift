import KernelCore
import CisumUIComponents
import Foundation
import PluginScene
import Testing

private actor SceneProbePlugin: SuperPlugin {
    static let shared = SceneProbePlugin(sceneName: nil)
    nonisolated let sceneName: String?

    init(sceneName: String?) {
        self.sceneName = sceneName
    }

    nonisolated var id: String { "probe.\(sceneName ?? "nil")" }

    @MainActor
    func addSceneItem() -> String? { sceneName }
}

private actor SceneDependentProbePlugin: SuperPlugin {
    static let shared = SceneDependentProbePlugin()

    nonisolated var id: String { "scene-dependent-probe" }

    static var metadata: PluginMetadata {
        PluginMetadata(
            id: "scene-dependent-probe",
            displayName: "Scene dependent probe",
            description: "",
            order: 0
        )
    }

    @MainActor
    func onBoot(kernel: CisumKernel) async throws {
        guard kernel.scene != nil else {
            throw CisumKernelError.serviceNotAvailable(service: "SceneProviding")
        }
    }
}

@MainActor
struct ScenePluginTests {
    @Test
    func registersAndUnregistersSceneProvider() async throws {
        let kernel = CisumKernel()
        let plugin = ScenePlugin()

        try await plugin.onBoot(kernel: kernel)
        #expect(kernel.scene != nil)

        try await plugin.onShutdown(kernel: kernel)
        #expect(kernel.scene == nil)
    }

    @Test
    func contributesSceneSettingsNavigationItem() {
        let item = ScenePlugin().addSettingNavigationItem()

        #expect(item?.id == "scene")
        #expect(item?.title == "Scene")
        #expect(item?.iconName == "rectangle.3.group")
    }

    @Test
    func bootsBeforeSameOrderSceneDependentPlugins() async throws {
        let kernel = CisumKernel()
        let manager = kernel.pluginManager

        // The dependent plugin is intentionally registered first and has the
        // old order value 0. ScenePlugin must still register its provider first.
        manager.initializePlugins([
            SceneDependentProbePlugin(),
            ScenePlugin(),
        ])

        try await manager.onBoot(kernel: kernel)
        #expect(kernel.scene != nil)
    }

    private func makePersistenceURL() throws -> URL {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("PluginSceneTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory.appendingPathComponent("current-scene.json")
    }

    private func makeManager() -> BuiltinPluginManager {
        let manager = BuiltinPluginManager()
        manager.initializePlugins([
            SceneProbePlugin(sceneName: "音乐库"),
            SceneProbePlugin(sceneName: "有声书"),
        ])
        return manager
    }

    private func clearLegacyPersistence() {
        UserDefaults.standard.removeObject(forKey: "currentSceneName")
        UserDefaults.standard.removeObject(forKey: "currentPluginID")
        NSUbiquitousKeyValueStore.default.removeObject(forKey: "currentSceneName")
        NSUbiquitousKeyValueStore.default.removeObject(forKey: "currentPluginID")
    }

    @Test
    func persistsAndRestoresCurrentSceneFromDisk() throws {
        let persistenceURL = try makePersistenceURL()
        defer { try? FileManager.default.removeItem(at: persistenceURL.deletingLastPathComponent()) }

        let first = SceneService(manager: makeManager(), persistenceURL: persistenceURL)
        first.restoreCurrentScene()
        try first.setCurrentScene("有声书")

        let second = SceneService(manager: makeManager(), persistenceURL: persistenceURL)
        second.restoreCurrentScene()

        #expect(second.currentSceneName == "有声书")
        #expect(FileManager.default.fileExists(atPath: persistenceURL.path))
    }

    @Test
    func fallsBackToFirstSceneWhenPersistedSceneIsUnknown() throws {
        let persistenceURL = try makePersistenceURL()
        defer { try? FileManager.default.removeItem(at: persistenceURL.deletingLastPathComponent()) }
        let data = Data(#"{"sceneName":"不存在","pluginID":null}"#.utf8)
        try data.write(to: persistenceURL)

        let service = SceneService(manager: makeManager(), persistenceURL: persistenceURL)
        service.restoreCurrentScene()

        #expect(service.currentSceneName == "音乐库")
    }

    @Test
    func rejectsUnknownScene() throws {
        let persistenceURL = try makePersistenceURL()
        defer { try? FileManager.default.removeItem(at: persistenceURL.deletingLastPathComponent()) }
        let service = SceneService(manager: makeManager(), persistenceURL: persistenceURL)

        #expect(throws: SceneContributionError.self) {
            try service.setCurrentScene("不存在")
        }
    }

    @Test
    func notifiesObserversAfterSceneChangesAndSupportsCancellation() throws {
        let persistenceURL = try makePersistenceURL()
        clearLegacyPersistence()
        defer {
            clearLegacyPersistence()
            try? FileManager.default.removeItem(at: persistenceURL.deletingLastPathComponent())
        }
        let service = SceneService(manager: makeManager(), persistenceURL: persistenceURL)
        var observedScenes: [String?] = []
        let handle = service.addObserver { event in
            if case let .selectionChanged(sceneName) = event {
                observedScenes.append(sceneName)
                #expect(service.currentSceneName == sceneName)
            }
        }
        defer { handle.cancel() }

        service.restoreCurrentScene()
        try service.setCurrentScene("有声书")
        #expect(observedScenes == ["音乐库", "有声书"])

        handle.cancel()
        try service.setCurrentScene("音乐库")
        #expect(observedScenes == ["音乐库", "有声书"])
    }
}
