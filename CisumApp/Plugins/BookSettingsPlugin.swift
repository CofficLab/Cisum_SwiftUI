import MagicKit
import OSLog
import PluginBookSettings
import SwiftUI

/**
 * 有声书设置插件，提供仓库信息展示。
 *
 * 复用 `BookSettings` 视图，不重新创建仓库或监听。
 */
actor BookSettingsPlugin: SuperPlugin {
    static let shared = BookSettingsPlugin()
    static var shouldRegister: Bool { true }
    static var order: Int { BookSettingsPluginInfo.order }
    nonisolated var title: String { BookSettingsPluginInfo.title }
    nonisolated var description: String { BookSettingsPluginInfo.description }
    let iconName = BookSettingsPluginInfo.iconName

    @MainActor
    func addSettingView() -> AnyView? {
        AnyView(BookSettingsPluginView())
    }
}

private struct BookSettingsPluginView: View {
    @State private var refreshToken = 0

    var body: some View {
        BookSettingsView(refreshToken: refreshToken) {
            BookPlugin.getBookDisk()
        }
        .onStorageLocationChanged {
            refreshToken += 1
        }
    }
}
