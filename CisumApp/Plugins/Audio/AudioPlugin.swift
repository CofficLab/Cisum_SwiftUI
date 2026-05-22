import CisumUI
import Foundation
import MagicKit
import OSLog
import SwiftData
import SwiftUI

actor AudioPlugin: SuperPlugin, SuperLog {
    static let emoji = "🎧"
    static let verbose = true
    static var shouldRegister: Bool { true }
    /// 免费版本最大音频数量
    static let maxAudioCount = 100
    static let supportedExtensions = [
        "mp3",
        "m4a",
        "flac",
        "wav",
    ]

    /// 注册顺序设为 1，确保在 AudioScenePlugin (order: 0) 之后执行
    static var order: Int { 1 }

    #if DEBUG
        static let dbDirName = "audios_debug"
    #else
        static let dbDirName = "audios"
    #endif

    let title = "音乐"
    let description = "音频播放功能"
    let iconName: String = .cisumIconMusicNote

    @MainActor func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View {
        AnyView(AudioRootView { content() })
    }

    @MainActor static func getAudioDisk() -> URL? {
        guard let storageRoot = Config.getStorageRoot() else {
            return nil
        }

        return storageRoot.appendingPathComponent(Self.dbDirName)
    }

    @MainActor static func getAudioRepo() -> AudioRepo? {
        guard let disk = Self.getAudioDisk() else {
            return nil
        }

        guard let repo = try? AudioRepo(disk: disk, reason: "AudioPlugin") else {
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
