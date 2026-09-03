import CisumKernel
import CisumUIComponents
import Foundation
import ProviderScene

/// `SceneProviding` 的磁盘持久化实现。
@MainActor
public final class SceneService: ObservableObject, SceneProviding {
    private struct PersistedScene: Codable {
        let sceneName: String
        let pluginID: String?
    }

    private static let legacySceneKey = "currentSceneName"
    private static let legacyPluginIDKey = "currentPluginID"
    private static let persistenceDirectoryName = "Cisum"
    private static let persistenceFileName = "current-scene.json"

    private let manager: BuiltinPluginManager
    private let persistenceURL: URL?
    private var observers: [WeakObserver] = []

    @Published public private(set) var currentSceneName: String?

    public init(
        manager: BuiltinPluginManager,
        persistenceURL: URL? = nil
    ) {
        self.manager = manager
        self.persistenceURL = persistenceURL ?? Self.defaultPersistenceURL()
        self.currentSceneName = nil
    }

    public var sceneNames: [String] {
        manager.enabledPlugins.compactMap { $0.addSceneItem() }
    }

    public func setCurrentScene(_ sceneName: String) throws {
        guard sceneNames.contains(sceneName) else {
            throw SceneContributionError.unknownScene(sceneName)
        }
        if currentSceneName == sceneName {
            if loadPersistedSceneName() == sceneName { return }
            try persistScene(sceneName)
            return
        }

        try persistScene(sceneName)
        currentSceneName = sceneName
        notify(.selectionChanged(sceneName: sceneName))
    }

    /// 从磁盘恢复当前场景；无记录或记录失效时回落到首个场景。
    public func restoreCurrentScene() {
        let names = sceneNames
        guard !names.isEmpty else {
            updateCurrentScene(nil)
            return
        }

        let saved = loadPersistedSceneName() ?? loadLegacySceneName()
        if let saved, names.contains(saved) {
            updateCurrentScene(saved)
            return
        }

        let first = names[0]
        updateCurrentScene(first)
        try? persistScene(first)
    }

    public func plugin(for sceneName: String) -> (any SuperPlugin)? {
        manager.enabledPlugins.first { $0.addSceneItem() == sceneName }
    }

    @discardableResult
    public func addObserver(
        _ callback: @escaping (SceneProvidingEvent) -> Void
    ) -> any SceneProvidingObserverHandle {
        let observer = Observer(owner: self, callback: callback)
        observers.append(WeakObserver(observer))
        return observer
    }

    private func updateCurrentScene(_ sceneName: String?) {
        guard currentSceneName != sceneName else { return }
        currentSceneName = sceneName
        notify(.selectionChanged(sceneName: sceneName))
    }

    private func remove(_ observer: Observer) {
        observers.removeAll { $0.observer === observer }
    }

    private func notify(_ event: SceneProvidingEvent) {
        observers.removeAll { $0.observer == nil }
        for observer in observers {
            observer.observer?.invoke(event)
        }
    }

    private static func defaultPersistenceURL() -> URL? {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent(Self.persistenceDirectoryName, isDirectory: true)
            .appendingPathComponent(Self.persistenceFileName, isDirectory: false)
    }

    private func loadPersistedSceneName() -> String? {
        guard let persistenceURL,
              let data = try? Data(contentsOf: persistenceURL),
              let persisted = try? JSONDecoder().decode(PersistedScene.self, from: data) else {
            return nil
        }
        return persisted.sceneName
    }

    private func loadLegacySceneName() -> String? {
        UserDefaults.standard.string(forKey: Self.legacySceneKey)
            ?? NSUbiquitousKeyValueStore.default.string(forKey: Self.legacySceneKey)
    }

    private func persistScene(_ sceneName: String) throws {
        let pluginID = plugin(for: sceneName)?.id
        let persisted = PersistedScene(sceneName: sceneName, pluginID: pluginID)
        let data = try JSONEncoder().encode(persisted)

        if let persistenceURL {
            let directory = persistenceURL.deletingLastPathComponent()
            try FileManager.default.createDirectory(
                at: directory,
                withIntermediateDirectories: true
            )
            try data.write(to: persistenceURL, options: .atomic)
        }

        // 保留旧版键，便于从旧版本升级后继续恢复，也让已有调用方保持兼容。
        UserDefaults.standard.set(sceneName, forKey: Self.legacySceneKey)
        if let pluginID {
            UserDefaults.standard.set(pluginID, forKey: Self.legacyPluginIDKey)
        }
    }

    private final class Observer: SceneProvidingObserverHandle {
        private weak var owner: SceneService?
        private let callback: (SceneProvidingEvent) -> Void
        private var cancelled = false

        init(owner: SceneService, callback: @escaping (SceneProvidingEvent) -> Void) {
            self.owner = owner
            self.callback = callback
        }

        func cancel() {
            guard !cancelled else { return }
            cancelled = true
            owner?.remove(self)
        }

        func invoke(_ event: SceneProvidingEvent) {
            guard !cancelled else { return }
            callback(event)
        }
    }

    private final class WeakObserver {
        weak var observer: Observer?

        init(_ observer: Observer) {
            self.observer = observer
        }
    }
}