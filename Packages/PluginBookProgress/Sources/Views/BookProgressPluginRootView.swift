import CisumUIComponents
import OSLog
import PluginBook
import ProviderScene
import SwiftData
import SwiftUI

struct BookProgressPluginRootView<Content>: View where Content: View {
    private let scene: (any SceneProviding)?
    private let content: Content

    init(scene: (any SceneProviding)?, @ViewBuilder content: () -> Content) {
        self.scene = scene
        self.content = content()
    }

    var body: some View {
        BookProgressRootView(
            targetScene: .audiobooks,
            scene: scene,
            currentBookURL: { BookSettingRepo.getCurrent() },
            currentBookTime: { BookSettingRepo.getCurrentTime() },
            storeCurrentBookURL: { BookSettingRepo.storeCurrent($0) },
            storeCurrentBookTime: { BookSettingRepo.storeCurrentTime($0) },
            saveBookState: { bookURL, currentURL, time in
                do {
                    let dbRootURL = try await MainActor.run {
                        try BookPluginHost.getDBRootDir()
                    }
                    try await Task.detached(priority: .utility) {
                        let container = try BookConfig.getContainer(dbRootURL: dbRootURL)
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
