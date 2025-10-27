import Foundation
import MagicCore
import OSLog
import SwiftData
import SwiftUI

actor AudioPlugin: SuperPlugin, SuperLog, PluginRegistrant {
    static let emoji = "🎧"
    #if DEBUG
        static let dbDirName = "audios_debug"
    #else
        static let dbDirName = "audios"
    #endif

    let hasPoster = true
    let description = "歌曲仓库"
    let iconName = "music.note"
    let isGroup = true
    let verbose = false

    @MainActor func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View {
        AnyView(AudioRootView { content() })
    }

    @MainActor func addDBView(reason: String) -> AnyView? {
        if verbose {
            os_log("\(self.t)🍋🍋🍋 AddDBView")
        }

        return AnyView(AudioDBView())
    }

    @MainActor func addPosterView() -> AnyView? { AnyView(AudioPoster()) }

    @MainActor func addSettingView() -> AnyView? {
        if verbose {
            os_log("\(self.t)🍋🍋🍋 AddSettingView")
        }

        return AnyView(AudioSettings())
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
        PluginRegistry.registerSync(order: 0) { Self() }
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
