import Foundation
import Testing
@testable import PluginPluginManager

// MARK: - PluginManagerStateStore 磁盘存储行为测试

@MainActor
struct PluginManagerStateStoreTests {
    private func makePluginDataDirectory() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent("cisum-plugin-state-\(UUID().uuidString)", isDirectory: true)
    }

    @Test
    func storePersistsOverridesToPluginDataDirectoryPlist() throws {
        let pluginDir = makePluginDataDirectory()
        let store = PluginManagerStateStore(pluginDataDirectory: pluginDir)

        store.setOverride(true, for: "plugin.alpha")
        store.setOverride(false, for: "plugin.beta")

        // 文件落在 <pluginDataDirectory>/plugin-enabled-overrides.plist
        let fileURL = pluginDir
            .appendingPathComponent("plugin-enabled-overrides.plist")
        #expect(FileManager.default.fileExists(atPath: fileURL.path))

        // 新实例（模拟重启）能从磁盘重载
        let reloaded = PluginManagerStateStore(pluginDataDirectory: pluginDir)
        #expect(reloaded.override(for: "plugin.alpha") == true)
        #expect(reloaded.override(for: "plugin.beta") == false)
        #expect(reloaded.override(for: "plugin.gamma") == nil)
    }

    @Test
    func clearOverrideRemovesEntryAndPersists() throws {
        let pluginDir = makePluginDataDirectory()
        let store = PluginManagerStateStore(pluginDataDirectory: pluginDir)
        store.setOverride(true, for: "plugin.alpha")

        store.clearOverride(for: "plugin.alpha")
        #expect(store.override(for: "plugin.alpha") == nil)

        let reloaded = PluginManagerStateStore(pluginDataDirectory: pluginDir)
        #expect(reloaded.override(for: "plugin.alpha") == nil)
    }

    @Test
    func resetClearsAllOverrides() throws {
        let pluginDir = makePluginDataDirectory()
        let store = PluginManagerStateStore(pluginDataDirectory: pluginDir)
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

        let pluginDir = makePluginDataDirectory()
        let store = PluginManagerStateStore(pluginDataDirectory: pluginDir)

        // 迁移后旧 key 被清除
        #expect(store.override(for: "plugin.legacy") == false)
        #expect(store.override(for: "plugin.kept") == true)
        #expect(UserDefaults.standard.dictionary(forKey: legacyKey) == nil)
    }
}
