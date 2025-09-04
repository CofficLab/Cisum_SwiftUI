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
    @MainActor var audioProvider: AudioProvider?
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

        guard let audioProvider = self.audioProvider else {
            return nil
        }

        return AnyView(AudioSettings().environmentObject(audioProvider))
    }

    @MainActor func onPause(playMan: PlayManWrapper) {
        AudioStateRepo.storeCurrentTime(playMan.currentTime)
    }

    func onCurrentURLChanged(url: URL) {
        if verbose {
            os_log("\(self.t)🍋 OnPlayAssetUpdate with asset \(url.title)")
        }

        AudioStateRepo.storeCurrent(url)
    }

    @MainActor func getDisk() -> URL? {
        self.disk
    }

    @MainActor
    func onPlayModeChange(mode: String, asset: PlayAsset?) async throws {
        guard self.initialized else {
            return
        }

        AudioStateRepo.storePlayMode(mode)

        guard let audioDB = audioDB else {
            return
        }

        switch PlayMode(rawValue: mode) {
        case .loop:
            break
        case .sequence, .repeatAll:
            await audioDB.sort(asset?.url, reason: self.className + ".OnPlayModeChange")
        case .shuffle:
            try await audioDB.sortRandom(asset?.url, reason: self.className + ".OnPlayModeChange", verbose: false)
        case .none:
            break
        }
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
        self.audioProvider = AudioProvider(disk: disk, db: self.audioDB!)
        self.initialized = true

        var assetTarget: URL?
        var timeTarget: TimeInterval = 0
        var liked = false

        if let url = AudioStateRepo.getCurrent(), let audio = await self.audioDB?.find(url) {
            assetTarget = audio
            liked = await self.audioDB?.isLiked(audio) ?? false

            if let time = AudioStateRepo.getCurrentTime() {
                timeTarget = time
            }
        } else {
            if verbose {
                os_log("\(self.t)⚠️⚠️⚠️ No current audio URL, try find first")
            }

            guard let audioDB = audioDB else {
                os_log("\(self.t)⚠️⚠️⚠️ AudioDB not found")
                return
            }

            if let first = try? await audioDB.getFirst() {
                assetTarget = first
                liked = await audioDB.isLiked(first)
            } else {
                os_log("\(self.t)⚠️⚠️⚠️ No audio found")
            }
        }

        if let asset = assetTarget {
            await playMan.play(asset, autoPlay: false)
            await playMan.seek(time: timeTarget)
            playMan.setLike(liked)
        }

        let mode = AudioStateRepo.getPlayMode()
        if let mode = mode {
            playMan.setPlayMode(mode)
        }
    }

    @MainActor
    func onPlayPrev(playMan: PlayManWrapper, current: URL?, currentGroup: String?, verbose: Bool) async throws {
        if currentGroup != self.id {
            return
        }

        guard let audioDB = audioDB else {
            os_log("\(self.t)⚠️ AudioDB not found")
            return
        }

        let asset = try await audioDB.getPrevOf(current, verbose: false)

        if let asset = asset {
            await playMan.play(asset, autoPlay: playMan.playing)
        } else {
            throw AudioPluginError.NoPrevAsset
        }
    }

    @MainActor
    func onPlayNext(playMan: PlayManWrapper, current: URL?, currentGroup: String?, verbose: Bool) async throws {
        if currentGroup != self.id {
            return
        }

        guard let audioDB = audioDB else {
            os_log("\(self.t)⚠️ AudioDB not found")
            return
        }

        let asset = try await audioDB.getNextOf(current, verbose: false)
        if let asset = asset {
            await playMan.play(asset, autoPlay: true)
        } else {
            throw AudioPluginError.NoNextAsset
        }
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
        self.audioProvider?.updateDisk(disk)
    }

    @MainActor
    func onLike(asset: URL?, liked: Bool) async throws {
        guard let audioDB = audioDB else {
            os_log("\(self.t)⚠️ AudioDB not found")
            return
        }

        await audioDB.like(asset, liked: liked)
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
