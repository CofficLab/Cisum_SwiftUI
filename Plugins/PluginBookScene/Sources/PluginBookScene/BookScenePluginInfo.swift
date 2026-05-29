import Foundation

public enum BookScenePluginInfo {
    public static let title = String(localized: "Audiobook Scene", table: "Book-Scene", bundle: .module)
    public static let description = String(localized: "Provides audiobook scene", table: "Book-Scene", bundle: .module)
    public static let iconName = "book.closed"
    public static let sceneName = "Audiobooks"
    public static let order = 0
}
