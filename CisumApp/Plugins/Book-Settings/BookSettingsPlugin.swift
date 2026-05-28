import MagicKit
import OSLog
import SwiftUI

/**
 * 有声书设置插件，提供仓库信息展示。
 *
 * 复用 `BookSettings` 视图，不重新创建仓库或监听。
 */
actor BookSettingsPlugin: SuperPlugin {
    static let shared = BookSettingsPlugin()
    static var shouldRegister: Bool { true }
    static var order: Int { 11 }
    nonisolated var title: String { String(localized: "Audiobook Settings", table: "Book-Settings") }
    nonisolated var description: String { String(localized: "Audiobook plugin settings", table: "Book-Settings") }
    let iconName = "gearshape"

    @MainActor
    func addSettingView() -> AnyView? {
        return AnyView(BookSettings())
    }
}
