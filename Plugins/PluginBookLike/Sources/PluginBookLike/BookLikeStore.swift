import Foundation

public struct BookLikeItem: Hashable, Identifiable {
    public let url: URL
    public let title: String

    public var id: String { url.absoluteString }
}

public enum BookLikeStore {
    private static let likedBooksKey = "PluginBookLike.likedBooks"

    public static func likedBooks(defaults: UserDefaults = .standard) -> [BookLikeItem] {
        let storedBooks = defaults.dictionary(forKey: likedBooksKey) as? [String: String] ?? [:]

        return storedBooks.compactMap { rawURL, title in
            guard let url = URL(string: rawURL) else { return nil }
            return BookLikeItem(url: url, title: title)
        }
        .sorted {
            $0.title.localizedStandardCompare($1.title) == .orderedAscending
        }
    }

    public static func setLiked(_ liked: Bool, url: URL, defaults: UserDefaults = .standard) {
        var storedBooks = defaults.dictionary(forKey: likedBooksKey) as? [String: String] ?? [:]
        let key = url.absoluteString

        if liked {
            storedBooks[key] = displayTitle(for: url)
        } else {
            storedBooks.removeValue(forKey: key)
        }

        defaults.set(storedBooks, forKey: likedBooksKey)
    }

    public static func removeAll(defaults: UserDefaults = .standard) {
        defaults.removeObject(forKey: likedBooksKey)
    }

    private static func displayTitle(for url: URL) -> String {
        let title = url.lastPathComponent
        return title.isEmpty ? url.absoluteString : title
    }
}
