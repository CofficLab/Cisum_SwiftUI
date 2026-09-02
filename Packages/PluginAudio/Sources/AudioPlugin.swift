import CisumKernel
import CisumUI
import Foundation
import PluginAudioLike
import SwiftUI

public actor AudioPlugin: SuperPlugin, CisumKernelPlugin {
    public static let shared = AudioPlugin()
    public static let metadata = PluginMetadata(
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

    /// OnReady 阶段（Storage 服务已注册）将 `AudioPluginHost` 桥接到内核
    /// `StorageProviding`，使历史插件代码无需改动即可继续工作。
    @MainActor
    public func onReady(kernel: CisumKernel) async throws {
        guard let storage = kernel.storage else { return }
        AudioPluginHost.configure(
            databaseURL: { try storage.databaseFile(name: $0) },
            storageRoot: { storage.storageRoot },
            hasStorageLocation: { storage.hasUsableStorageLocation },
            storageLocationDidChangeNotifications: [.cisumStorageLocationDidChange, .cisumStorageLocationDidReset]
        )
    }

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
