import PluginBookLike
import Testing
import Foundation

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

@Test func bookLikeStoreIgnoresEmptyStoredURLs() throws {
    let suiteName = "PluginBookLikeTests-\(UUID().uuidString)"
    let defaults = try #require(UserDefaults(suiteName: suiteName))
    defer {
        defaults.removePersistentDomain(forName: suiteName)
    }

    defaults.set([
        "": "Broken Favorite",
        "file:///tmp/Cisum%20Books/Valid%20Book": "Valid Book",
    ], forKey: "PluginBookLike.likedBooks")

    let likedBooks = BookLikeStore.likedBooks(defaults: defaults)

    #expect(likedBooks.map(\.title) == ["Valid Book"])
}
