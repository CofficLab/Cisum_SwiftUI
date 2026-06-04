import CisumUI
import Foundation
import MagicKit
import SwiftUI

public actor BookPlugin: SuperPlugin {
    public static let shared = BookPlugin()
    public static let metadata = PluginMetadata(
        id: "BookPlugin",
        displayName: BookPluginInfo.title,
        description: BookPluginInfo.description,
        iconName: BookPluginInfo.iconName,
        order: 1
    )

    public static let keyOfCurrentBookURL = BookPluginInfo.keyOfCurrentBookURL
    public static let keyOfCurrentBookTime = BookPluginInfo.keyOfCurrentBookTime
    public static let dirName = BookPluginInfo.dirName
    public static let supportedExtensions = BookPluginInfo.supportedExtensions

    @MainActor
    public func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View {
        AnyView(
            BookRootView(
                dbRootURL: { try BookPluginHost.getDBRootDir() },
                bookDisk: { Self.getBookDisk() },
                storageLocationDidChangeNotifications: BookPluginHost.storageLocationDidChangeNotifications,
                content: content
            )
        )
    }

    @MainActor
    public static func getBookDisk() -> URL? {
        guard let storageRoot = BookPluginHost.getStorageRoot() else {
            return nil
        }

        let disk = storageRoot.appendingPathComponent(Self.dirName, isDirectory: true)
        return try? disk.ensureDirectory()
    }
}
