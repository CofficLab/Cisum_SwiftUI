import CisumKernel
import CisumUI
import Foundation
import ProviderStorage
import SwiftUI

public actor BookPlugin: SuperPlugin, CisumKernelPlugin {
    public static let shared = BookPlugin()
    public static let metadata = PluginMetadata(
        displayName: BookPluginInfo.title,
        description: BookPluginInfo.description,
        iconName: BookPluginInfo.iconName,
        order: 1
    )

    public static let keyOfCurrentBookURL = BookPluginInfo.keyOfCurrentBookURL
    public static let keyOfCurrentBookTime = BookPluginInfo.keyOfCurrentBookTime
    public static let dirName = BookPluginInfo.dirName
    public static let supportedExtensions = BookPluginInfo.supportedExtensions

    /// OnReady 阶段（Storage 服务已注册）将 `BookPluginHost` 桥接到内核
    /// `StorageProviding`。
    @MainActor
    public func onReady(kernel: CisumKernel) async throws {
        guard let storage = kernel.storage else { return }
        BookPluginHost.configure(
            dbRoot: { storage.databaseRoot },
            storageRoot: { storage.storageRoot },
            storageLocationDidChangeNotifications: [.cisumStorageLocationDidChange, .cisumStorageLocationDidReset]
        )
    }

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
