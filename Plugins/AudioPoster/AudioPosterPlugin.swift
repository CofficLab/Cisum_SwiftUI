import MagicKit
import OSLog
import SwiftUI

/**
 * 音频海报插件，提供音频列表的海报视图。
 *
 * 复用现有的 `AudioPoster` 视图，不额外创建仓库或监听。
 */
actor AudioPosterPlugin: SuperPlugin, SuperLog, PluginRegistrant {
    nonisolated static let emoji = "🖼️"

    let title = "音乐仓库"
    let description = "适用于听歌的场景"
    let iconName = "photo.on.rectangle"
    let isGroup = false
    let verbose = false

    @MainActor
    func addPosterView() -> AnyView? {
        if verbose {
            os_log("\(self.t)🖼️ 加载海报视图")
        }

        return AnyView(AudioPoster())
    }
}

// MARK: - PluginRegistrant

extension AudioPosterPlugin {
    @objc static func register() {
        // 紧随 AudioPlugin 之后注册
        PluginRegistry.registerSync(order: 1) { Self() }
    }
}

