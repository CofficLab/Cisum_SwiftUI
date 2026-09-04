import Foundation

public enum StoragePluginLocation: String, Codable, Sendable {
    case icloud
    case local
    case custom

    public var emojiTitle: String {
        emoji + " " + title
    }

    public var emoji: String {
        switch self {
        case .icloud: return "🌐"
        case .local: return "💾"
        case .custom: return "🔧"
        }
    }

    public var title: String {
        switch self {
        case .icloud: return "iCloud"
        case .local: return "Local"
        case .custom: return "Custom"
        }
    }

    public var description: String {
        switch self {
        case .icloud: return "Use iCloud for data storage"
        case .local: return "Use local storage for data"
        case .custom: return "Use custom storage location for data"
        }
    }
}
