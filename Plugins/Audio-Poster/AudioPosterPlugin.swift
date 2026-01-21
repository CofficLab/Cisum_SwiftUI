import MagicKit
import OSLog
import SwiftUI

/**
 * 音频海报插件，提供音频列表的海报视图。
 *
 * 复用现有的 `AudioPoster` 视图，不额外创建仓库或监听。
 */
actor AudioPosterPlugin: SuperPlugin, SuperLog {
    nonisolated static let emoji = "🖼️"
    static let verbose = false
    static var shouldRegister: Bool { true }

    /// 注册顺序设为 6，在音频插件之后执行
    static var order: Int { 6 }

    let title = "音频海报"
    let description = "提供音频的海报视图"
    let iconName = "photo.on.rectangle"
    

    @MainActor
    func addPosterView() -> AnyView? {
        if Self.verbose {
            os_log("\(self.t)🖼️ 加载海报视图")
        }

        return AnyView(AudioPoster())
    }
}

