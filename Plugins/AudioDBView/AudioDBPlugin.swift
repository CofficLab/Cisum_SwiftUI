import MagicKit
import OSLog
import SwiftUI

/**
 * 音频数据库插件：提供音频仓库列表视图。
 */
actor AudioDBPlugin: SuperPlugin, SuperLog {
    nonisolated static let emoji = "🎵"
    private nonisolated static let targetPluginId = String(describing: AudioPlugin.self)
    private static let verbose = true
    /// 注册顺序设为 1，在 CopyPlugin 之后执行
    static var order: Int { 1 }

    let title = "音频仓库"
    let description = "音频文件数据库视图"
    let iconName = "externaldrive"
    

    @MainActor
    func addTabView(reason: String, currentPluginId: String?) -> (view: AnyView, label: String)? {
        guard currentPluginId == nil || currentPluginId == Self.targetPluginId else { return nil }

        return (AnyView(AudioDBView()), "音乐仓库")
    }
}

// MARK: - Preview

#if os(macOS)
    #Preview("App - Large") {
        ContentView()
            .inRootView()
            .frame(width: 600, height: 1000)
    }

    #Preview("App - Small") {
        ContentView()
            .inRootView()
            .frame(width: 600, height: 600)
    }
#endif

#if os(iOS)
    #Preview("iPhone") {
        ContentView()
            .inRootView()
    }
#endif
