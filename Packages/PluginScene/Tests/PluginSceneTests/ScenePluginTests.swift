import CisumKernel
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
}
