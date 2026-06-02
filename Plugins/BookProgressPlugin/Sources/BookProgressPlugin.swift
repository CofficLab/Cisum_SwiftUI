import CisumUI
import OSLog
import BookPlugin
import BookScenePlugin
import SwiftData
import SwiftUI

public actor BookProgressPlugin: SuperPlugin {
    public static let shared = BookProgressPlugin()
    public static let metadata = PluginMetadata(
        id: "BookProgressPlugin",
        displayName: BookProgressPluginInfo.title,
        description: BookProgressPluginInfo.description,
        iconName: BookProgressPluginInfo.iconName,
        order: BookProgressPluginInfo.order
    )

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

enum BookProgressStatePersistence {
    @MainActor
    static func save(
        bookURL: URL,
        currentURL: URL?,
        time: TimeInterval?,
        container: ModelContainer
    ) throws {
        let context = ModelContext(container)
        let descriptor = BookState.descriptorOf(bookURL)

        let existingState = try context.fetch(descriptor).first
            ?? context.fetch(BookState.descriptorAll).first { state in
                BookState.representsSameBookURL(state.url, as: bookURL)
            }

        if let existingState {
            existingState.currentURL = currentURL
            if let time {
                existingState.time = time
            }
            existingState.updateAt = .now
        } else {
            let newState = BookState(url: bookURL, currentURL: currentURL, time: time ?? 0)
            context.insert(newState)
        }

        try context.save()
        NotificationCenter.postBookStateUpdated(bookURL: bookURL)
    }
}
