import CisumUI
import Foundation
import MagicKit
import OSLog
import PluginAudio
import PluginAudioLike
import SwiftData
import SwiftUI

actor AudioPlugin: SuperPlugin, SuperLog {
    static let shared = AudioPlugin()
    static let emoji = "🎧"
    static let verbose = true
    static var shouldRegister: Bool { true }
    /// 免费版本最大音频数量
    static let maxAudioCount = AudioPluginInfo.maxAudioCount
    static let supportedExtensions = AudioPluginInfo.supportedExtensions

    /// 注册顺序设为 1，确保在 AudioScenePlugin (order: 0) 之后执行
    static var order: Int { 1 }

    #if DEBUG
        static let dbDirName = AudioPluginInfo.debugDBDirName
    #else
        static let dbDirName = AudioPluginInfo.dbDirName
    #endif

    nonisolated var title: String { String(localized: String.LocalizationValue(AudioPluginInfo.titleKey), table: AudioPluginInfo.table) }
    nonisolated var description: String { String(localized: String.LocalizationValue(AudioPluginInfo.descriptionKey), table: AudioPluginInfo.table) }
    let iconName: String = .cisumIconMusicNote

    @MainActor func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View {
        AnyView(AudioRootView(
            databaseURL: { try Config.createDatabaseFile(name: "audio") },
            hasStorageLocation: { Config.getStorageLocation() != nil },
            storageLocationDidChangeNotifications: [.storageLocationDidReset, .storageLocationUpdated],
            content: content
        ))
    }

    @MainActor static func getAudioDisk() -> URL? {
        guard let storageRoot = Config.getStorageRoot() else {
            return nil
        }

        return storageRoot.appendingPathComponent(Self.dbDirName)
    }

    @MainActor static func getAudioRepo() -> AudioRepo? {
        try? AudioLikeRepositoryConfiguration.configure(databaseURL: Config.createDatabaseFile(name: "audio_like"))

        guard let disk = Self.getAudioDisk() else {
            return nil
        }

        guard let repo = try? AudioRepo(disk: disk, databaseURL: Config.createDatabaseFile(name: "audio"), reason: "AudioPlugin") else {
            return nil
        }

        return repo
    }
}

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}
