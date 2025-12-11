import MagicCore
import OSLog
import SwiftUI

/**
 * 音频数据库插件：提供音频仓库列表视图。
 *
 * 复用现有的 `AudioDBView`，不重新创建仓库或监听。
 * 需要宿主注入同一个 `AudioProvider` 环境对象。
 */
actor AudioDBPlugin: SuperPlugin, SuperLog, PluginRegistrant {
    nonisolated static let emoji = "📂🎵"

    let title = "音频仓库"
    let description = "音频文件数据库视图"
    let iconName = "externaldrive"
    let isGroup = false
    let hasPoster = false
    
    private let verbose = true

    @MainActor
    func addDBView(reason: String) -> AnyView? {
        if verbose {
            os_log("\(self.t)📂 加载音频数据库视图 \(reason)")
        }

        return AnyView(AudioDBView())
    }
}

// MARK: - PluginRegistrant

extension AudioDBPlugin {
    @objc static func register() {
        // 紧随 AudioPlugin 之后注册
        PluginRegistry.registerSync(order: 1) { Self() }
    }
}

