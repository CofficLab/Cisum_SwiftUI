import MagicKit
import OSLog
import SwiftUI

/**
 * 有声书海报插件，提供有声书封面视图。
 *
 * 复用 `BookPoster` 视图，不额外创建仓库或监听。
 */
actor BookPosterPlugin: SuperPlugin, SuperLog {
    nonisolated static let emoji = "🖼️"
    static let verbose = false

    /// 注册顺序设为 9，在其他书籍插件之后执行
    static var order: Int { 9 }

    let title = "有声书海报"
    let description = "提供有声书的封面视图"
    let iconName = "photo.on.rectangle"
    

    @MainActor
    func addPosterView() -> AnyView? {
        if Self.verbose {
            os_log("\(self.t)🖼️ 加载有声书海报视图")
        }

        return AnyView(BookPoster())
    }
}

