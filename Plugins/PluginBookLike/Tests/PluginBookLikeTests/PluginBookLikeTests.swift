@testable import PluginBookLike
import Testing
import Foundation

private final class NotificationObserverToken: @unchecked Sendable {
    var value: NSObjectProtocol?
}

@Test func pluginInfoExportsRegistrationMetadata() {
    #expect(BookLikePluginInfo.iconName == "heart")
    #expect(BookLikePluginInfo.order == 6)
}

@Test
@MainActor
func pluginExposesSettingsView() {
    let view = BookLikePlugin.shared.addSettingView()

    #expect(view != nil)
}

@Test func bookLikeStatusChangesAreAcceptedOnlyInActiveScene() {
    #expect(BookLikeStatusChangePolicy.shouldAcceptChange(isSceneActive: true))
    #expect(!BookLikeStatusChangePolicy.shouldAcceptChange(isSceneActive: false))
}

@Test func bookLikeStatusNotificationIsDeliveredOnMainThread() async {
    let url = URL(fileURLWithPath: "/tmp/Cisum Books/Main Thread Book")

    let deliveredOnMainThread = await withCheckedContinuation { continuation in
        let token = NotificationObserverToken()
        token.value = NotificationCenter.default.addObserver(
            forName: .BookLikeStatusChanged,
            object: nil,
            queue: nil
        ) { _ in
            if let observer = token.value {
                NotificationCenter.default.removeObserver(observer)
                token.value = nil
            }
            continuation.resume(returning: Thread.isMainThread)
        }

        Task.detached {
            NotificationCenter.postBookLikeStatusChanged(url: url, liked: true)
        }
    }

    #expect(deliveredOnMainThread)
}

@Test func bookLikeStorePersistsRealLikedBooks() throws {
    let suiteName = "PluginBookLikeTests-\(UUID().uuidString)"
    let defaults = try #require(UserDefaults(suiteName: suiteName))
    defer {
        defaults.removePersistentDomain(forName: suiteName)
    }

    let first = URL(fileURLWithPath: "/tmp/Cisum Books/First Book")
    let second = URL(fileURLWithPath: "/tmp/Cisum Books/Second Book")

    BookLikeStore.setLiked(true, url: second, defaults: defaults)
    BookLikeStore.setLiked(true, url: first, defaults: defaults)

    #expect(BookLikeStore.likedBooks(defaults: defaults).map(\.title) == ["First Book", "Second Book"])

    BookLikeStore.setLiked(false, url: first, defaults: defaults)

    let likedBooks = BookLikeStore.likedBooks(defaults: defaults)
    #expect(likedBooks.count == 1)
    #expect(likedBooks.first?.url == second)
}

@Test func bookLikeStoreMatchesSymlinkedBooks() throws {
    let suiteName = "PluginBookLikeTests-\(UUID().uuidString)"
    let defaults = try #require(UserDefaults(suiteName: suiteName))
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    let realBook = root.appendingPathComponent("Real Book", isDirectory: true)
    let linkedBook = root.appendingPathComponent("Linked Book", isDirectory: true)
    defer {
        defaults.removePersistentDomain(forName: suiteName)
        try? FileManager.default.removeItem(at: root)
    }

    try FileManager.default.createDirectory(at: realBook, withIntermediateDirectories: true)
    try FileManager.default.createSymbolicLink(at: linkedBook, withDestinationURL: realBook)

    BookLikeStore.setLiked(true, url: realBook, defaults: defaults)
    BookLikeStore.setLiked(true, url: linkedBook, defaults: defaults)

    let likedBooks = BookLikeStore.likedBooks(defaults: defaults)
    #expect(likedBooks.count == 1)
    #expect(likedBooks.first?.url == linkedBook)

    BookLikeStore.setLiked(false, url: realBook, defaults: defaults)

    #expect(BookLikeStore.likedBooks(defaults: defaults).isEmpty)
}

@Test func bookLikeStoreIgnoresEmptyStoredURLs() throws {
    let suiteName = "PluginBookLikeTests-\(UUID().uuidString)"
    let defaults = try #require(UserDefaults(suiteName: suiteName))
    defer {
        defaults.removePersistentDomain(forName: suiteName)
    }

    defaults.set([
        "": "Broken Favorite",
        "file:///tmp/Cisum%20Books/Valid%20Book": "Valid Book",
        "/tmp/Cisum Books/Legacy Book": "Legacy Book",
        "not a url": "Invalid Book",
    ], forKey: "PluginBookLike.likedBooks")

    let likedBooks = BookLikeStore.likedBooks(defaults: defaults)

    #expect(likedBooks.map(\.title) == ["Legacy Book", "Valid Book"])
}
