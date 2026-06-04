import CisumUI
import Foundation
import MagicKit
import AudioLikePlugin
import SwiftUI

public actor AudioPlugin: SuperPlugin {
    public static let shared = AudioPlugin()
    public static let metadata = PluginMetadata(
        id: "AudioPlugin",
        displayName: String(localized: String.LocalizationValue(AudioPluginInfo.titleKey), bundle: .module),
        description: String(localized: String.LocalizationValue(AudioPluginInfo.descriptionKey), bundle: .module),
        iconName: .cisumIconMusicNote,
        order: 1
    )

    public static let maxAudioCount = AudioPluginInfo.maxAudioCount
    public static let supportedExtensions = AudioPluginInfo.supportedExtensions

    #if DEBUG
        public static let dbDirName = AudioPluginInfo.debugDBDirName
    #else
        public static let dbDirName = AudioPluginInfo.dbDirName
    #endif

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
