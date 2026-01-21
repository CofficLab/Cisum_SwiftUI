import Foundation
import MagicKit
import OSLog
import SwiftData
import SwiftUI

actor AudioPlugin: SuperPlugin, SuperLog {
    static let emoji = "🎧"
    static let verbose = true
    
    /// 注册顺序设为 1，确保在 AudioProgressPlugin (order: 0) 之后执行
    /// 这样内核会先应用进度管理，再应用音频功能
    static var order: Int { 1 }

    #if DEBUG
        static let dbDirName = "audios_debug"
    #else
        static let dbDirName = "audios"
    #endif

    let title = "音乐"
    let description = "音频播放功能"
    let iconName = "music.note"

    /// 提供"音乐库"场景
    @MainActor func addSceneItem() -> String? {
        return "音乐库"
    }

    @MainActor func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View {
        AnyView(AudioRootView { content() })
    }

    @MainActor func getDisk() -> URL? { Self.getAudioDisk() }

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

#Preview("UserDefaultsDebugView") {
    RootView {
        UserDefaultsDebugView(defaultSearchText: "AudioPlugin")
    }
    .frame(width: 500)
    .frame(height: 600)
}

#Preview("App - Large") {
    ContentView()
    .inRootView()
        .frame(width: 600, height: 1000)
}

#Preview("App - Small") {
    ContentView()
    .inRootView()
        .frame(width: 600, height: 600)
}

#if os(iOS)
    #Preview("iPhone") {
        ContentView()
    .inRootView()
    }
#endif
