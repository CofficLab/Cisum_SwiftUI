import Foundation
import MagicKit
import OSLog
import PluginBook
import SwiftUI

actor BookPlugin: SuperPlugin, SuperLog {
    static let shared = BookPlugin()
    static let keyOfCurrentBookURL = BookPluginInfo.keyOfCurrentBookURL
    static let keyOfCurrentBookTime = BookPluginInfo.keyOfCurrentBookTime
    nonisolated static var emoji: String { BookPluginInfo.emoji }
    private static var verbose: Bool { true }
    static var shouldRegister: Bool { true }
    static var order: Int { 1 }

    let title: String = BookPluginInfo.title
    let description: String = BookPluginInfo.description
    let iconName: String = BookPluginInfo.iconName
    static let dirName = BookPluginInfo.dirName
    static let supportedExtensions = BookPluginInfo.supportedExtensions

    @MainActor var disk: URL?

    @MainActor func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View {
        AnyView(
            BookRootView(
                dbRootURL: { try Config.getDBRootDir() },
                bookDisk: { Self.getBookDisk() },
                storageLocationDidChangeNotifications: [
                    .storageLocationDidReset,
                    .storageLocationUpdated
                ],
                content: content
            )
        )
    }

    @MainActor
    func onWillAppear(playMan: PlayMan, currentSceneName: String?, storage: StorageLocation?) async throws {
        guard currentSceneName == BookScenePlugin.sceneName else {
            return
        }

        self.disk = Config.cloudDocumentsDir?.appendingFolder(Self.dirName)
    }

    @MainActor
    static func getBookDisk() -> URL? {
        guard let storageRoot = Config.getStorageRoot() else {
            return nil
        }

        return try? storageRoot
            .appendingPathComponent(Self.dirName, isDirectory: true)
            .createIfNotExist()
    }
}
