import MagicKit
import OSLog
import PluginBook
import PluginBookDBView
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

    nonisolated var title: String { String(localized: String.LocalizationValue(BookDBPluginInfo.titleKey), table: BookDBPluginInfo.table) }
    nonisolated var description: String { String(localized: String.LocalizationValue(BookDBPluginInfo.descriptionKey), table: BookDBPluginInfo.table) }
    let iconName = BookDBPluginInfo.iconName
    

    @MainActor
    func addTabView(reason: String, currentSceneName: String?, demoMode: Bool = false) -> (view: AnyView, label: String)? {
        guard currentSceneName == BookScenePlugin.sceneName else { return nil }

        if BookDBPlugin.verbose {
            os_log("\(self.t)✅ 返回 BookDBView")
        }
        guard let dbRoot = try? Config.getDBRootDir() else {
            os_log(.error, "\(self.t)❌ 无法获取数据库目录")
            return nil
        }
        let dependencies = BookDBViewDependencies(
            dbRoot: dbRoot,
            bookDisk: BookPlugin.getBookDisk(),
            isDesktop: Config.isDesktop,
            isNotDesktop: Config.isNotDesktop
        )
        let view = BookDBView()
            .bookDBViewDependencies(dependencies)
        return (AnyView(view), String(localized: String.LocalizationValue(BookDBPluginInfo.titleKey), table: BookDBPluginInfo.table))
    }
}
