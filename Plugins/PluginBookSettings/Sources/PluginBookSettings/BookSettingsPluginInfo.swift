import Foundation

public enum BookSettingsPluginInfo {
    public static let title = String(localized: "Audiobook Settings", table: "Book-Settings", bundle: .module)
    public static let description = String(localized: "Audiobook plugin settings", table: "Book-Settings", bundle: .module)
    public static let iconName = "gearshape"
    public static let emoji = "🔊"
    public static let order = 11
}
