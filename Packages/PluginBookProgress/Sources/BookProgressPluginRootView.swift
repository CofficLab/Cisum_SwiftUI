import CisumUI
import OSLog
import PluginBook
import PluginBookScene
import SwiftData
import SwiftUI

struct BookProgressPluginRootView<Content>: View where Content: View {
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
                    try await MainActor.run {
                        let container = try BookConfig.getContainer(dbRootURL: BookPluginHost.getDBRootDir())
                        try BookProgressStatePersistence.save(
                            bookURL: bookURL,
                            currentURL: currentURL,
                            time: time,
                            container: container
                        )
                    }
                } catch {
                    os_log(.error, "BookProgressPlugin failed to save book state: \(error.localizedDescription)")
                }
            }
        ) {
            content
        }
    }
}
