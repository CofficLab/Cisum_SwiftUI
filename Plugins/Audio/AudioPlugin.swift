import Foundation
import MagicKit
import OSLog
import SwiftData
import SwiftUI

actor AudioPlugin: SuperPlugin, SuperLog {
    static let keyOfCurrentAudioURL = "AudioPluginCurrentAudioURL"
    static let keyOfCurrentAudioTime = "AudioPluginCurrentAudioTime"
    static let keyOfCurrentPlayMode = "AudioPluginCurrentPlayMode"
    static let emoji = "🎧"

    let label = "Audio"
    let hasPoster = true
    let description = "作为歌曲仓库，只关注文件，文件夹将被忽略"
    let iconName = "music.note"
    let isGroup = true

    @MainActor var dirName: String { Config.isDebug ? "audios_debug" : "audios" }
    @MainActor var disk: URL?
    @MainActor var audioProvider: AudioProvider?
    @MainActor var audioDB: AudioDB?
    @MainActor var initialized: Bool = false
    @MainActor var container: ModelContainer?

    @MainActor func addDBView(reason: String) -> AnyView? {
        let verbose = false

        guard let audioProvider = self.audioProvider else {
            os_log(.error, "\(self.t)AddDBView, AudioProvider not found")
            return AnyView(EmptyView())
        }

        guard let audioDB = audioDB else {
            os_log(.error, "\(self.t)AddDBView, AudioDB not found")
            return AnyView(EmptyView())
        }

        guard let container = self.container else {
            os_log(.error, "\(self.t)AddDBView, ModelContainer not found")
            return AnyView(EmptyView())
        }

        if verbose {
            os_log("\(self.t)🍋🍋🍋 AddDBView")
        }

        return AnyView(AudioDBView()
            .modelContainer(container)
            .environmentObject(audioDB)
            .environmentObject(audioProvider)
        )
    }

    @MainActor func addPosterView() -> AnyView? {  AnyView(AudioPoster()) }

    @MainActor func addSettingView() -> AnyView? {
        let verbose = false

        if verbose {
            os_log("\(self.t)🍋🍋🍋 AddSettingView")
        }

        guard let audioProvider = self.audioProvider else {
            return nil
        }

        return AnyView(AudioSettings().environmentObject(audioProvider))
    }

    @MainActor func onPause(playMan: PlayManWrapper) {
        AudioPlugin.storeCurrentTime(playMan.currentTime)
    }

    func onCurrentURLChanged(url: URL) {
        let verbose = true

        if verbose {
            os_log("\(self.t)🍋🍋🍋 OnPlayAssetUpdate with asset \(url.title)")
        }

        AudioPlugin.storeCurrent(url)
    }

    @MainActor func getDisk() -> URL? {
        self.disk
    }

    func onPlayModeChange(mode: String, asset: PlayAsset?) async throws {
        guard await self.initialized else {
            return
        }

        os_log("\(self.t)🍋🍋🍋 OnPlayModelChange with asset \(asset?.title ?? "nil")")

        AudioPlugin.storePlayMode(mode)

        guard let audioDB = await audioDB else {
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
        let verbose = false

        if verbose {
            os_log("\(self.a)with storage \(storage?.emojiTitle ?? "nil")")
        }
        
        info("init with storage  \(storage?.emojiTitle ?? "nil")")

        switch storage {
        case .local, .none:
            disk = Config.localDocumentsDir?.appendingPathComponent(self.dirName)
        case .icloud:
            disk = Config.cloudDocumentsDir?.appendingPathComponent(self.dirName)
        case .custom:
            disk = Config.localDocumentsDir?.appendingPathComponent(self.dirName)
        }

        guard let disk = disk else {
            os_log(.error, "\(self.t)⚠️ AudioPlugin.onInit: disk == nil")

            throw AudioPluginError.NoDisk
        }

        self.container = try AudioConfig.getContainer()
        self.audioDB = try await AudioDB(disk: disk, reason: self.className + ".onInit", verbose: false)
        self.audioProvider = AudioProvider(disk: disk)
        self.initialized = true

        var assetTarget: URL?
        var timeTarget: TimeInterval = 0
        var liked = false

        if let url = AudioPlugin.getCurrent(), let audio = await self.audioDB?.find(url) {
            assetTarget = audio
            liked = await self.audioDB?.isLiked(audio) ?? false

            if let time = AudioPlugin.getCurrentTime() {
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
            await playMan.play(url: asset, autoPlay: false)
            await playMan.seek(time: timeTarget)

            os_log("\(self.t)🍋🍋🍋 Set like to \(liked)")
            playMan.setLike(liked)
        }

        let mode = AudioPlugin.getPlayMode()
        if let mode = mode {
            playMan.setPlayMode(mode)
        }
    }

    func onPlayPrev(playMan: PlayManWrapper, current: URL?, currentGroup: String?, verbose: Bool) async throws {
        if currentGroup != self.id {
            return
        }

        guard let audioDB = await audioDB else {
            os_log("\(self.t)⚠️ AudioDB not found")
            return
        }

        let asset = try await audioDB.getPrevOf(current, verbose: false)

        if let asset = asset {
            await playMan.play(url: asset, autoPlay: playMan.playing)
        } else {
            throw AudioPluginError.NoPrevAsset
        }
    }

    func onPlayNext(playMan: PlayManWrapper, current: URL?, currentGroup: String?, verbose: Bool) async throws {
        if currentGroup != self.id {
            return
        }

        guard let audioDB = await audioDB else {
            os_log("\(self.t)⚠️ AudioDB not found")
            return
        }

        let asset = try await audioDB.getNextOf(current, verbose: false)
        if let asset = asset {
            await playMan.play(url: asset, autoPlay: playMan.playing)
        } else {
            throw AudioPluginError.NoNextAsset
        }
    }

    @MainActor func onStorageLocationChange(storage: StorageLocation?) async throws {
        os_log("\(self.t)🍋🍋🍋 OnStorageLocationChange to \(storage?.emojiTitle ?? "nil")")

        switch storage {
        case .local, .none:
            disk = Config.localDocumentsDir?.appendingPathComponent(self.dirName)
        case .icloud:
            disk = Config.cloudDocumentsDir?.appendingPathComponent(self.dirName)
        case .custom:
            disk = Config.localDocumentsDir?.appendingPathComponent(self.dirName)
        }

        guard let disk = disk else {
            fatalError("AudioPlugin.onInit: disk == nil")
        }

        os_log("\(self.t)🍋🍋🍋 OnStorageLocationChange to \(disk.absoluteString)")

        self.audioDB?.changeRoot(url: disk)
        self.audioProvider?.updateDisk(disk)
    }

    func onLike(asset: URL?, liked: Bool) async throws {
        guard let audioDB = await audioDB else {
            os_log("\(self.t)⚠️ AudioDB not found")
            return
        }

        await audioDB.like(asset, liked: liked)
    }
}

// MARK: Store

extension AudioPlugin {
    static func storePlayMode(_ mode: String) {
        UserDefaults.standard.set(mode, forKey: keyOfCurrentPlayMode)

        // Store mode as string for CloudKit
        NSUbiquitousKeyValueStore.default.set(mode, forKey: keyOfCurrentPlayMode)
        NSUbiquitousKeyValueStore.default.synchronize()
    }

    static func storeCurrent(_ url: URL?, verbose: Bool = false) {
        if verbose {
            os_log("\(Self.t)🍋🍋🍋 Store current audio URL: \(url?.absoluteString ?? "")")
        }

        UserDefaults.standard.set(url, forKey: keyOfCurrentAudioURL)

        // Store URL as string for CloudKit
        NSUbiquitousKeyValueStore.default.set(url?.absoluteString ?? "", forKey: keyOfCurrentAudioURL)
        NSUbiquitousKeyValueStore.default.synchronize()
    }

    static func storeCurrentTime(_ time: TimeInterval) {
        UserDefaults.standard.set(time, forKey: keyOfCurrentAudioTime)

        // Store time as string for CloudKit
        NSUbiquitousKeyValueStore.default.set(String(time), forKey: keyOfCurrentAudioTime)
        NSUbiquitousKeyValueStore.default.synchronize()
    }

    static func getPlayMode() -> PlayMode? {
        // First, try to get the mode from UserDefaults
        if let mode = UserDefaults.standard.string(forKey: keyOfCurrentPlayMode) {
            return PlayMode(rawValue: mode)
        }

        // If not found in UserDefaults, try to get from iCloud
        if let modeString = NSUbiquitousKeyValueStore.default.string(forKey: keyOfCurrentPlayMode),
           let mode = PlayMode(rawValue: modeString) {
            return mode
        }

        return nil
    }

    static func getCurrent() -> URL? {
        // First, try to get the URL from UserDefaults
        if let url = UserDefaults.standard.url(forKey: keyOfCurrentAudioURL) {
            return url
        }

        // If not found in UserDefaults, try to get from iCloud
        if let urlString = NSUbiquitousKeyValueStore.default.string(forKey: keyOfCurrentAudioURL),
           let url = URL(string: urlString) {
            // If found in iCloud, update UserDefaults for future local access
            UserDefaults.standard.set(url, forKey: keyOfCurrentAudioURL)
            return url
        }

        return nil
    }

    static func getCurrentTime() -> TimeInterval? {
        // First, try to get the time from UserDefaults
        let time = UserDefaults.standard.double(forKey: keyOfCurrentAudioTime)
        if time > 0 { // Since 0 is the default value when key doesn't exist
            return time
        }

        // If not found in UserDefaults, try to get from iCloud
        if let timeString = NSUbiquitousKeyValueStore.default.string(forKey: keyOfCurrentAudioTime),
           let time = TimeInterval(timeString) {
            // If found in iCloud, update UserDefaults for future local access
            UserDefaults.standard.set(time, forKey: keyOfCurrentAudioTime)
            return time
        }

        return nil
    }
}

extension Notification.Name {
    static let AudiosUpdatedNotification = Notification.Name("AudiosUpdatedNotification")
    static let AudioUpdatedNotification = Notification.Name("AudioUpdatedNotification")
    static let SyncingNotification = Notification.Name("SyncingNotification")
    static let URLDeletedNotification = Notification.Name("URLDeletedNotification")
    static let URLsDeletedNotification = Notification.Name("URLsDeletedNotification")
}

enum AudioPluginError: Error, LocalizedError {
    case NoNextAsset
    case NoPrevAsset
    case NoDisk

    var errorDescription: String? {
        switch self {
        case .NoNextAsset:
            return "No next asset"
        case .NoPrevAsset:
            return "No prev asset"
        case .NoDisk:
            return "No disk"
        }
    }
}
