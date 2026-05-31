import CisumUI
import Foundation
import MagicKit
import PluginAudioLike
import SwiftUI

public actor AudioPlugin: SuperPlugin {
    public static let shared = AudioPlugin()
    public static var shouldRegister: Bool { true }
    public static var order: Int { 1 }

    public static let maxAudioCount = AudioPluginInfo.maxAudioCount
    public static let supportedExtensions = AudioPluginInfo.supportedExtensions

    #if DEBUG
        public static let dbDirName = AudioPluginInfo.debugDBDirName
    #else
        public static let dbDirName = AudioPluginInfo.dbDirName
    #endif

    public nonisolated var title: String {
        String(localized: String.LocalizationValue(AudioPluginInfo.titleKey), table: AudioPluginInfo.table, bundle: .module)
    }

    public nonisolated var description: String {
        String(localized: String.LocalizationValue(AudioPluginInfo.descriptionKey), table: AudioPluginInfo.table, bundle: .module)
    }

    public nonisolated var iconName: String { .cisumIconMusicNote }

    @MainActor
    public func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View {
        AnyView(AudioRootView(
            databaseURL: { try AudioPluginHost.createDatabaseFile(name: "audio") },
            hasStorageLocation: { AudioPluginHost.hasStorageLocation() },
            storageLocationDidChangeNotifications: AudioPluginHost.storageLocationDidChangeNotifications,
            content: content
        ))
    }

    @MainActor
    public static func getAudioDisk() -> URL? {
        guard let storageRoot = AudioPluginHost.getStorageRoot() else {
            return nil
        }

        let disk = storageRoot.appendingPathComponent(Self.dbDirName, isDirectory: true)
        return try? disk.ensureDirectory()
    }

    @MainActor
    public static func getAudioRepo() -> AudioRepo? {
        try? AudioLikeRepositoryConfiguration.configure(databaseURL: AudioPluginHost.createDatabaseFile(name: "audio_like"))

        guard let disk = Self.getAudioDisk() else {
            return nil
        }

        return try? AudioRepo(
            disk: disk,
            databaseURL: AudioPluginHost.createDatabaseFile(name: "audio"),
            reason: "AudioPlugin"
        )
    }
}

private extension URL {
    func ensureDirectory() throws -> URL {
        var isDirectory: ObjCBool = false
        if FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory), !isDirectory.boolValue {
            try FileManager.default.removeItem(at: self)
        } else if (try? FileManager.default.destinationOfSymbolicLink(atPath: path)) != nil {
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
