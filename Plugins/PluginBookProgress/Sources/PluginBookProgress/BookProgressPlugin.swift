import CisumUI
import OSLog
import PluginBook
import PluginBookScene
import SwiftUI

public actor BookProgressPlugin: SuperPlugin {
    public static let shared = BookProgressPlugin()
    public static var shouldRegister: Bool { true }
    public static var order: Int { BookProgressPluginInfo.order }

    public nonisolated var title: String { BookProgressPluginInfo.title }
    public nonisolated var description: String { BookProgressPluginInfo.description }
    public nonisolated var iconName: String { BookProgressPluginInfo.iconName }

    @MainActor
    public func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View {
        AnyView(BookProgressPluginRootView(content: content))
    }
}

private struct BookProgressPluginRootView<Content>: View where Content: View {
    @Environment(\.currentSceneName) private var currentSceneName
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        BookProgressRootView(
            targetSceneName: BookScenePlugin.sceneName,
            currentSceneName: { currentSceneName },
            currentBookURL: { BookSettingRepo.getCurrent() },
            currentBookTime: { BookSettingRepo.getCurrentTime() },
            storeCurrentBookURL: { BookSettingRepo.storeCurrent($0) },
            storeCurrentBookTime: { BookSettingRepo.storeCurrentTime($0) },
            saveBookState: { bookURL, currentURL, time in
                do {
                    let container = try await MainActor.run {
                        try BookConfig.getContainer(dbRootURL: BookPluginHost.getDBRootDir())
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
