import Foundation
import MagicKit
import OSLog
import SwiftUI

/// 插件数据仓库，负责处理插件相关的数据存取操作
@MainActor
class PluginRepo: SuperLog, SuperThread {
    nonisolated static let emoji = "📦"
    static let keyOfCurrentPluginID = "currentPluginID"
    static let keyOfCurrentSceneName = "currentSceneName"
    
    /// 存储当前选中的插件ID
    /// - Parameter pluginId: 插件ID
    func storeCurrentPluginId(_ pluginId: String) {
        guard !pluginId.isEmpty else {
            UserDefaults.standard.removeObject(forKey: Self.keyOfCurrentPluginID)
            NSUbiquitousKeyValueStore.default.removeObject(forKey: Self.keyOfCurrentPluginID)
            NSUbiquitousKeyValueStore.default.synchronize()
            return
        }

        UserDefaults.standard.set(pluginId, forKey: Self.keyOfCurrentPluginID)

        // 同步到 CloudKit
        NSUbiquitousKeyValueStore.default.set(pluginId, forKey: Self.keyOfCurrentPluginID)
        NSUbiquitousKeyValueStore.default.synchronize()
    }

    nonisolated static func storedIdentifier(from string: String?) -> String? {
        guard let string, !string.isEmpty else { return nil }
        return string
    }
    
    /// 获取当前选中的插件ID
    /// - Returns: 插件ID，如果没有则返回空字符串
    func getCurrentPluginId() -> String {
        // 首先尝试从 UserDefaults 获取
        if let id = Self.storedIdentifier(from: UserDefaults.standard.string(forKey: Self.keyOfCurrentPluginID)) {
            return id
        }

        // 如果 UserDefaults 中没有，尝试从 iCloud 获取
        if let id = Self.storedIdentifier(from: NSUbiquitousKeyValueStore.default.string(forKey: Self.keyOfCurrentPluginID)) {
            // 如果在 iCloud 中找到，更新 UserDefaults 以便将来本地访问
            UserDefaults.standard.set(id, forKey: Self.keyOfCurrentPluginID)
            return id
        }

        return ""
    }

    /// 存储当前选中的场景名称
    /// - Parameter sceneName: 场景名称
    func storeCurrentSceneName(_ sceneName: String) {
        guard !sceneName.isEmpty else {
            UserDefaults.standard.removeObject(forKey: Self.keyOfCurrentSceneName)
            NSUbiquitousKeyValueStore.default.removeObject(forKey: Self.keyOfCurrentSceneName)
            NSUbiquitousKeyValueStore.default.synchronize()
            return
        }

        UserDefaults.standard.set(sceneName, forKey: Self.keyOfCurrentSceneName)

        // 同步到 CloudKit
        NSUbiquitousKeyValueStore.default.set(sceneName, forKey: Self.keyOfCurrentSceneName)
        NSUbiquitousKeyValueStore.default.synchronize()
    }

    /// 获取当前选中的场景名称
    /// - Returns: 场景名称，如果没有则返回空字符串
    func getCurrentSceneName() -> String {
        // 首先尝试从 UserDefaults 获取
        if let sceneName = Self.storedIdentifier(from: UserDefaults.standard.string(forKey: Self.keyOfCurrentSceneName)) {
            return sceneName
        }

        // 如果 UserDefaults 中没有，尝试从 iCloud 获取
        if let sceneName = Self.storedIdentifier(from: NSUbiquitousKeyValueStore.default.string(forKey: Self.keyOfCurrentSceneName)) {
            // 如果在 iCloud 中找到，更新 UserDefaults 以便将来本地访问
            UserDefaults.standard.set(sceneName, forKey: Self.keyOfCurrentSceneName)
            return sceneName
        }

        return ""
    }
}

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}

#Preview("插件仓库调试") {
    PluginRepoDebugView()
}
