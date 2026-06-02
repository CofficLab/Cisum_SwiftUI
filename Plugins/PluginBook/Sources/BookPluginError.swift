import Foundation
import SwiftUI

// MARK: - Book Plugin Errors

public enum BookPluginError: Error, LocalizedError {
    case configurationMissing
    case NoNextAsset
    case NoPrevAsset
    case NoDisk
    case DiskNotFound
    case initialization(reason: String)

    public var errorDescription: String? {
        switch self {
        case .configurationMissing:
            return String(localized: "Book plugin host configuration is incomplete", table: "Book", bundle: .module)
        case .NoNextAsset:
            return String(localized: "No next chapter or file", table: "Book", bundle: .module)
        case .NoPrevAsset:
            return String(localized: "No previous chapter or file", table: "Book", bundle: .module)
        case .NoDisk:
            return String(localized: "Unable to access disk", table: "Book", bundle: .module)
        case .DiskNotFound:
            return String(localized: "Disk not found", table: "Book", bundle: .module)
        case .initialization(let reason):
            return String(localized: "Initialization failed: \(reason)", table: "Book", bundle: .module)
        }
    }

    public var failureReason: String? {
        switch self {
        case .configurationMissing:
            return String(localized: "The app has not injected database and storage path configuration.", table: "Book", bundle: .module)
        case .NoNextAsset:
            return String(localized: "The current item is already the last item.", table: "Book", bundle: .module)
        case .NoPrevAsset:
            return String(localized: "The current item is already the first item.", table: "Book", bundle: .module)
        case .NoDisk:
            return String(localized: "The specified disk path does not exist or cannot be accessed.", table: "Book", bundle: .module)
        case .DiskNotFound:
            return String(localized: "The specified disk path does not exist or cannot be accessed.", table: "Book", bundle: .module)
        case .initialization:
            return String(localized: "An error occurred while initializing the plugin.", table: "Book", bundle: .module)
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .configurationMissing:
            return String(localized: "Check the app startup flow.", table: "Book", bundle: .module)
        case .NoNextAsset, .NoPrevAsset:
            return String(localized: "Check the playback order or choose another item.", table: "Book", bundle: .module)
        case .NoDisk:
            return String(localized: "Check disk permissions and path settings.", table: "Book", bundle: .module)
        case .DiskNotFound:
            return String(localized: "Check disk permissions and path settings.", table: "Book", bundle: .module)
        case .initialization:
            return String(localized: "Try restarting the app or checking settings.", table: "Book", bundle: .module)
        }
    }
}
