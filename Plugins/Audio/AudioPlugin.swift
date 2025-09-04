import Foundation
import MagicCore
import OSLog
import SwiftData
import SwiftUI

actor AudioPlugin: SuperPlugin, SuperLog {
    static let emoji = "🎧"
    #if DEBUG
        static let dbDirName = "audios_debug"
    #else
        static let dbDirName = "audios"
    #endif

    let label = "Audio"
    let hasPoster = true
    let description = "作为歌曲仓库，只关注文件，文件夹将被忽略"
    let iconName = "music.note"
    let isGroup = true
    let verbose = true

    @MainActor var disk: URL?
    @MainActor var audioDB: AudioRepo?
    @MainActor var initialized: Bool = false
    @MainActor var container: ModelContainer?

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

    @MainActor
    func onWillAppear(playMan: PlayManWrapper, currentGroup: SuperPlugin?, storage: StorageLocation?) async throws {
        guard let currentGroup = currentGroup, currentGroup.label == self.label else {
            return
        }

        if verbose {
            os_log("\(self.a)with storage \(storage?.emojiTitle ?? "nil")")
        }

        guard let storage = storage else {
            return
        }

        switch storage {
        case .local:
            disk = Config.localDocumentsDir?.appendingFolder(Self.dbDirName)
        case .icloud:
            disk = Config.cloudDocumentsDir?.appendingFolder(Self.dbDirName)
        case .custom:
            disk = Config.localDocumentsDir?.appendingFolder(Self.dbDirName)
        }

        guard let disk = disk else {
            os_log(.error, "\(self.t)⚠️ AudioPlugin.onInit: disk == nil")

            throw AudioPluginError.NoDisk
        }

        self.disk = try disk.createIfNotExist()
        self.container = try AudioConfigRepo.getContainer()
        self.audioDB = try AudioRepo(disk: disk, reason: self.className + ".onInit", verbose: false)
        self.initialized = true
    }

    @MainActor func onStorageLocationChange(storage: StorageLocation?) async throws {
        switch storage {
        case .local, .none:
            disk = Config.localDocumentsDir?.appendingPathComponent(Self.dbDirName)
        case .icloud:
            disk = Config.cloudDocumentsDir?.appendingPathComponent(Self.dbDirName)
        case .custom:
            disk = Config.localDocumentsDir?.appendingPathComponent(Self.dbDirName)
        }

        guard let disk = disk else {
            fatalError("AudioPlugin.onInit: disk == nil")
        }

        self.audioDB?.changeRoot(url: disk)
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
