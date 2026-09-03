import Foundation
import Testing
@testable import KernelCore

// MARK: - PluginEnabledStateStore 磁盘存储行为测试

@MainActor
struct PluginEnabledStateStoreTests {
    private func makePluginDirectory() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent("cisum-plugin-state-\(UUID().uuidString)", isDirectory: true)
    }

    @Test
    func storePersistsOverridesToPluginDataDirectoryPlist() throws {
        let dir = makePluginDirectory()
        let store = PluginEnabledStateStore(pluginDirectory: dir)

        store.setOverride(true, for: "plugin.alpha")
        store.setOverride(false, for: "plugin.beta")

        // 文件落在 <pluginDirectory>/plugin-enabled-overrides.plist
        let fileURL = dir.appendingPathComponent("plugin-enabled-overrides.plist")
        #expect(FileManager.default.fileExists(atPath: fileURL.path))

        // 新实例（模拟重启）能从磁盘重载
        let reloaded = PluginEnabledStateStore(pluginDirectory: dir)
        #expect(reloaded.override(for: "plugin.alpha") == true)
        #expect(reloaded.override(for: "plugin.beta") == false)
        #expect(reloaded.override(for: "plugin.gamma") == nil)
    }

    @Test
    func clearOverrideRemovesEntryAndPersists() throws {
        let dir = makePluginDirectory()
        let store = PluginEnabledStateStore(pluginDirectory: dir)
        store.setOverride(true, for: "plugin.alpha")

        store.clearOverride(for: "plugin.alpha")
        #expect(store.override(for: "plugin.alpha") == nil)

        let reloaded = PluginEnabledStateStore(pluginDirectory: dir)
        #expect(reloaded.override(for: "plugin.alpha") == nil)
    }

    @Test
    func resetClearsAllOverrides() throws {
        let dir = makePluginDirectory()
        let store = PluginEnabledStateStore(pluginDirectory: dir)
        store.setOverride(true, for: "plugin.alpha")
        store.setOverride(false, for: "plugin.beta")

        store.reset()
        #expect(store.override(for: "plugin.alpha") == nil)
        #expect(store.override(for: "plugin.beta") == nil)
    }

    @Test
    func migratesLegacyUserDefaultsWhenFileEmpty() throws {
        let legacyKey = "com.coffic.cisum.pluginEnabledOverrides"
        // 清理遗留状态，保证测试可重复
        UserDefaults.standard.removeObject(forKey: legacyKey)
        UserDefaults.standard.set(
            ["plugin.legacy": false, "plugin.kept": true],
            forKey: legacyKey
        )

        defer { UserDefaults.standard.removeObject(forKey: legacyKey) }

        let dir = makePluginDirectory()
        let store = PluginEnabledStateStore(pluginDirectory: dir)

        // 迁移后旧 key 被清除
        #expect(store.override(for: "plugin.legacy") == false)
        #expect(store.override(for: "plugin.kept") == true)
        #expect(UserDefaults.standard.dictionary(forKey: legacyKey) == nil)
    }
}
