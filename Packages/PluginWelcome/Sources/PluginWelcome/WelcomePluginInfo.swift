import Foundation

public enum WelcomePluginInfo {
    public static let title = String(localized: "Welcome", table: "Welcome", bundle: .module)
    public static let description = String(localized: "Welcome screen", table: "Welcome", bundle: .module)
    public static let iconName = "hand.wave"
    public static let emoji = "👏"
    public static let order = -100
}
