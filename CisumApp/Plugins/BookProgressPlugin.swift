import Foundation
import MagicKit
import OSLog
import PluginBook
import PluginBookProgress
import SwiftUI

actor BookProgressPlugin: SuperPlugin, SuperLog {
    static let shared = BookProgressPlugin()
    static let emoji = BookProgressPluginInfo.emoji
    static let verbose = true
    static var shouldRegister: Bool { true }

    /// 注册顺序设为 5，在 BookPlugin 之后执行
    static var order: Int { BookProgressPluginInfo.order }

    nonisolated var title: String { BookProgressPluginInfo.title }
    nonisolated var description: String { BookProgressPluginInfo.description }
    let iconName = BookProgressPluginInfo.iconName
    

    /// 提供进度管理功能的根视图包装器
    @MainActor func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View {
        AnyView(BookProgressPluginRootView(content: content))
    }
}

private struct BookProgressPluginRootView<Content>: View where Content: View {
    @EnvironmentObject private var pluginProvider: PluginProvider

    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        BookProgressRootView(
            targetSceneName: BookScenePlugin.sceneName,
            currentSceneName: { pluginProvider.currentSceneName },
            currentBookURL: { BookSettingRepo.getCurrent() },
            currentBookTime: { BookSettingRepo.getCurrentTime() },
            storeCurrentBookURL: { BookSettingRepo.storeCurrent($0) },
            saveBookState: { bookURL, currentURL, time in
                do {
                    let container = try await MainActor.run {
                        try BookConfig.getContainer(dbRootURL: Config.getDBRootDir())
                    }
                    let db = await BookDB(container, reason: "BookProgressPlugin.saveBookState")
                    await db.updateBookCurrent(bookURL, currentURL: currentURL, time: time)
                } catch {
                    os_log(.error, "BookProgressPlugin failed to save book state: \(error.localizedDescription)")
                }
            }
        ) {
            content
        }
    }
}
