import Foundation
import MagicKit
import OSLog
import SwiftUI

/// 插件数据仓库，负责处理插件相关的数据存取操作
@MainActor
class PluginRepo: SuperLog, SuperThread {
    nonisolated static let emoji = "📦"
    static let keyOfCurrentPluginID = "currentPluginID"
    
    /// 存储当前选中的插件ID
    /// - Parameter pluginId: 插件ID
    func storeCurrentPluginId(_ pluginId: String) {
        UserDefaults.standard.set(pluginId, forKey: Self.keyOfCurrentPluginID)

        // 同步到 CloudKit
        NSUbiquitousKeyValueStore.default.set(pluginId, forKey: Self.keyOfCurrentPluginID)
        NSUbiquitousKeyValueStore.default.synchronize()
    }
    
    /// 获取当前选中的插件ID
    /// - Returns: 插件ID，如果没有则返回空字符串
    func getCurrentPluginId() -> String {
        // 首先尝试从 UserDefaults 获取
        if let id = UserDefaults.standard.string(forKey: Self.keyOfCurrentPluginID) {
            return id
        }

        // 如果 UserDefaults 中没有，尝试从 iCloud 获取
        if let id = NSUbiquitousKeyValueStore.default.string(forKey: Self.keyOfCurrentPluginID) {
            // 如果在 iCloud 中找到，更新 UserDefaults 以便将来本地访问
            UserDefaults.standard.set(id, forKey: Self.keyOfCurrentPluginID)
            return id
        }

        return ""
    }
}

#Preview("插件仓库调试") {
    PluginRepoDebugView()
}

#Preview("Small Screen") {
    RootView {
        ContentView()
    }
    .frame(width: 500)
    .frame(height: 600)
}

#Preview("Big Screen") {
    RootView {
        ContentView()
    }
    .frame(width: 800)
    .frame(height: 1200)
}
