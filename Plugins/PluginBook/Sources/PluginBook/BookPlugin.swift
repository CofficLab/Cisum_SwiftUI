import CisumUI
import Foundation
import MagicKit
import SwiftUI

public actor BookPlugin: SuperPlugin {
    public static let shared = BookPlugin()
    public static var shouldRegister: Bool { true }
    public static var order: Int { 1 }

    public static let keyOfCurrentBookURL = BookPluginInfo.keyOfCurrentBookURL
    public static let keyOfCurrentBookTime = BookPluginInfo.keyOfCurrentBookTime
    public static let dirName = BookPluginInfo.dirName
    public static let supportedExtensions = BookPluginInfo.supportedExtensions

    public nonisolated var title: String { BookPluginInfo.title }
    public nonisolated var description: String { BookPluginInfo.description }
    public nonisolated var iconName: String { BookPluginInfo.iconName }

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

private extension URL {
    func ensureDirectory() throws -> URL {
        var isDirectory: ObjCBool = false
        if FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory), !isDirectory.boolValue {
            try FileManager.default.removeItem(at: self)
        }

        try FileManager.default.createDirectory(
            at: self,
            withIntermediateDirectories: true,
            attributes: nil
        )

        return self
    }
}
