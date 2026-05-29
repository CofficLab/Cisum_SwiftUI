import Foundation

public enum BookControlPluginInfo {
    public static let title = String(localized: "Book Playback Control", table: "Book-Control", bundle: .module)
    public static let description = String(localized: "Book playback control, such as previous and next chapter", table: "Book-Control", bundle: .module)
    public static let iconName = "playpause"
    public static let emoji = "🎮📚"
    public static let order = 8
}
