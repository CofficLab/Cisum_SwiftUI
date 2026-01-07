import Foundation
import MagicCore
import OSLog
import SwiftData
import SwiftUI

actor AudioPlugin: SuperPlugin, SuperLog, PluginRegistrant {
    static let emoji = "🎧"
    static let verbose = true
    private static var enabled: Bool { true }

    #if DEBUG
        static let dbDirName = "audios_debug"
    #else
        static let dbDirName = "audios"
    #endif

    let title = "音乐库"
    let description = "歌曲仓库"
    let iconName = "music.note"
    let isGroup = true

    @MainActor func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View {
        AnyView(AudioRootView { content() })
    }

    @MainActor func getDisk() -> URL? { Self.getAudioDisk() }

    @MainActor
    static func getAudioDisk() -> URL? {
        guard let storageRoot = Config.getStorageRoot() else {
            return nil
        }

        return storageRoot.appendingPathComponent(Self.dbDirName)
    }
}

// MARK: - PluginRegistrant

extension AudioPlugin {
    @objc static func register() {
        guard Self.enabled else {
            return
        }

        if Self.verbose {
            os_log("\(self.t)🚀🚀🚀 Register")
        }
        // 注册顺序设为 1，确保在 AudioProgressPlugin (order: 0) 之后执行
        // 这样内核会先应用进度管理，再应用音频功能
        PluginRegistry.registerSync(order: 1) { Self() }
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
    AppPreview()
        .frame(width: 600, height: 1000)
}

#Preview("App - Small") {
    AppPreview()
        .frame(width: 600, height: 600)
}

#if os(iOS)
    #Preview("iPhone") {
        AppPreview()
    }
#endif
