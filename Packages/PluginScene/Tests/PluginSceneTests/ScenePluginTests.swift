import Foundation
import KernelCore
import ProviderScene
import PluginScene
import Testing

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

    @Test
    func exposesFixedBuiltInScenes() {
        let service = SceneService()

        #expect(service.scenes == AppScene.allCases)
        #expect(service.scenes == [.music, .audiobooks])
    }

    private func makePersistenceURL() throws -> URL {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("PluginSceneTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory.appendingPathComponent("current-scene.json")
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

        let first = SceneService(persistenceURL: persistenceURL)
        first.restoreCurrentScene()
        first.setCurrentScene(.audiobooks)

        let second = SceneService(persistenceURL: persistenceURL)
        second.restoreCurrentScene()

        #expect(second.currentScene == .audiobooks)
        #expect(FileManager.default.fileExists(atPath: persistenceURL.path))
    }

    @Test
    func fallsBackToFirstSceneWhenPersistedSceneIsUnknown() throws {
        let persistenceURL = try makePersistenceURL()
        defer { try? FileManager.default.removeItem(at: persistenceURL.deletingLastPathComponent()) }
        let data = Data(#"{"sceneName":"不存在","pluginID":null}"#.utf8)
        try data.write(to: persistenceURL)

        let service = SceneService(persistenceURL: persistenceURL)
        service.restoreCurrentScene()

        #expect(service.currentScene == .music)
    }

    @Test
    func notifiesObserversAfterSceneChangesAndSupportsCancellation() throws {
        let persistenceURL = try makePersistenceURL()
        clearLegacyPersistence()
        defer {
            clearLegacyPersistence()
            try? FileManager.default.removeItem(at: persistenceURL.deletingLastPathComponent())
        }
        let service = SceneService(persistenceURL: persistenceURL)
        var observedScenes: [AppScene?] = []
        let handle = service.addObserver { event in
            if case let .selectionChanged(scene) = event {
                observedScenes.append(scene)
                #expect(service.currentScene == scene)
            }
        }
        defer { handle.cancel() }

        service.restoreCurrentScene()
        service.setCurrentScene(.audiobooks)
        #expect(observedScenes == [.music, .audiobooks])

        handle.cancel()
        service.setCurrentScene(.music)
        #expect(observedScenes == [.music, .audiobooks])
    }
}
