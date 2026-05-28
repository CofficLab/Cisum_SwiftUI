import MagicKit
import OSLog
import SwiftUI

/**
 * 有声书数据库插件：提供书籍仓库视图。
 */
actor BookDBPlugin: SuperPlugin, SuperLog {
    static let shared = BookDBPlugin()
    nonisolated static let emoji = "📚📂"
    private static let verbose = true
    static var shouldRegister: Bool { true }
    /// 注册顺序设为 12，在其他插件之后执行
    static var order: Int { 12 }

    nonisolated var title: String { String(localized: "Audiobook Repository", table: "Book-DBView") }
    nonisolated var description: String { String(localized: "Audiobook database view", table: "Book-DBView") }
    let iconName = "books.vertical"
    

    @MainActor
    func addTabView(reason: String, currentSceneName: String?, demoMode: Bool = false) -> (view: AnyView, label: String)? {
        guard currentSceneName == BookScenePlugin.sceneName else { return nil }

        if BookDBPlugin.verbose {
            os_log("\(self.t)✅ 返回 BookDBView")
        }
        return (AnyView(BookDBView()), String(localized: "Audiobook Repository", table: "Book-DBView"))
    }
}
