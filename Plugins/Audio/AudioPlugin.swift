import Foundation
import MagicKit
import MagicUI
import OSLog
import SwiftUI

actor AudioPlugin: SuperPlugin, SuperLog {
    static let keyOfCurrentAudioURL = "AudioPluginCurrentAudioURL"
    static let keyOfCurrentAudioTime = "AudioPluginCurrentAudioTime"
    static let keyOfCurrentPlayMode = "AudioPluginCurrentPlayMode"
    static let emoji = "🎧"

    @MainActor
    var dirName: String { Config.isDebug ? "audios_debug" : "audios" }
    let label = "Audio"
    let hasPoster = true
    let description = "作为歌曲仓库，只关注文件，文件夹将被忽略"
    let iconName = "music.note"
    let isGroup = true

    @MainActor var disk: (any SuperStorage)?
    @MainActor var audioProvider: AudioProvider?
    @MainActor var audioDB: AudioDB?
    @MainActor var initialized: Bool = false

    @MainActor func addDBView(reason: String) -> AnyView? {
        let verbose = true

        guard let audioProvider = self.audioProvider else {
            os_log(.error, "\(self.t)AddDBView, AudioProvider not found")
            return AnyView(EmptyView())
        }

        guard let audioDB = audioDB else {
            os_log(.error, "\(self.t)AddDBView, AudioDB not found")
            return AnyView(EmptyView())
        }

        if verbose {
            os_log("\(self.t)🍋🍋🍋 AddDBView")
        }

        return AnyView(AudioDBView(verbose: verbose, reason: self.className)
            .modelContainer(AudioConfig.getContainer)
            .environmentObject(audioDB)
            .environmentObject(audioProvider)
        )
    }

    @MainActor
    func addPosterView() -> AnyView {
        os_log("\(self.t)🍋🍋🍋 AddPosterView")
        return AnyView(AudioPoster())
    }

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

    func onPause(playMan: PlayMan) {
        AudioPlugin.storeCurrentTime(playMan.currentTime)
    }

    func onPlayAssetUpdate(asset: PlayAsset?, currentGroup: SuperPlugin?) async throws {
        let verbose = false
        
        if verbose {
            os_log("\(self.t)🍋🍋🍋 OnPlayAssetUpdate with asset \(asset?.title ?? "nil")")
        }

        if currentGroup?.id != self.id {
            return
        }

        AudioPlugin.storeCurrent(asset?.url)
    }

    @MainActor func getDisk() -> (any SuperStorage)? {
        self.disk
    }

    func onPlayModeChange(mode: PlayMode, asset: PlayAsset?) async throws {
        guard await self.initialized else {
            return
        }

        os_log("\(self.t)🍋🍋🍋 OnPlayModelChange with asset \(asset?.title ?? "nil")")

        AudioPlugin.storePlayMode(mode)

        guard let audioDB = await audioDB else {
            return
        }

        switch mode {
        case .loop:
            break
        case .sequence, .repeatAll:
            await audioDB.sort(asset?.url, reason: self.className + ".OnPlayModeChange")
        case .shuffle:
            try await audioDB.sortRandom(asset?.url, reason: self.className + ".OnPlayModeChange", verbose: true)
        }
    }

    @MainActor
    func onWillAppear(playMan: PlayManWrapper, currentGroup: SuperPlugin?, storage: StorageLocation?) async throws {
        let verbose = true

        if currentGroup?.id != self.id {
            return
        }

        if verbose {
            os_log("\(self.a)with storage \(storage?.emojiTitle ?? "nil")")
        }

        switch storage {
        case .local, .none:
            disk = LocalStorage.make(self.dirName, verbose: false, reason: self.className + ".onInit")
        case .icloud:
            disk = CloudStorage.make(self.dirName, verbose: false, reason: self.className + ".onInit")
        case .custom:
            disk = LocalStorage.make(self.dirName, verbose: false, reason: self.className + ".onInit")
        }

        guard let disk = disk else {
            os_log(.error, "\(self.t)⚠️ AudioPlugin.onInit: disk == nil")
            
            throw AudioPluginError.NoDisk
        }

        self.audioDB = AudioDB(disk: disk, reason: self.className + ".onInit", verbose: false)
        self.audioProvider = AudioProvider(disk: disk)
        self.initialized = true
        
        var assetTarget: URL?
        var timeTarget: TimeInterval = 0

        if let url = AudioPlugin.getCurrent(), let audio = await self.audioDB?.find(url) {
            assetTarget = audio

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
            } else {
                os_log("\(self.t)⚠️⚠️⚠️ No audio found")
            }
        }
        
        if let asset = assetTarget {
            await playMan.play(url: asset)
            await playMan.seek(time: timeTarget)
        }

        let mode = AudioPlugin.getPlayMode()
        if let mode = mode {
            playMan.setPlayMode(mode)
        }
    }

    func onPlayPrev(playMan: PlayManWrapper, current: PlayAsset?, currentGroup: SuperPlugin?, verbose: Bool) async throws {
        os_log("\(self.t)OnPlayPrev")

        guard let audioDB = await audioDB else {
            return
        }

        let asset = try await audioDB.getPrevOf(current?.url, verbose: false)

        if let asset = asset {
            await playMan.play(url: asset)
        } else {
            throw AudioPluginError.NoPrevAsset
        }
    }

    func onPlayNext(playMan: PlayManWrapper, current: PlayAsset?, currentGroup: SuperPlugin?, verbose: Bool) async throws {
        if currentGroup?.id != self.id {
            return
        }

        guard let audioDB = await audioDB else {
            return
        }

        let asset = try await audioDB.getNextOf(current?.url, verbose: false)
        if let asset = asset {
            await playMan.play(url: asset)
        } else {
            throw AudioPluginError.NoNextAsset
        }
    }
    
//    @MainActor
//    func onStorageLocationChange(storage: StorageLocation?) async throws {
//        switch storage {
//        case .local, .none:
//            disk = LocalStorage.make(self.dirName, verbose: false, reason: self.className + ".onInit")
//        case .icloud:
//            disk = CloudStorage.make(self.dirName, verbose: false, reason: self.className + ".onInit")
//        case .custom:
//            disk = LocalStorage.make(self.dirName, verbose: false, reason: self.className + ".onInit")
//        }
//        
//        guard let disk = disk else {
//            fatalError("AudioPlugin.onInit: disk == nil")
//        }
//        
//        self.audioDB?.changeDisk(disk: disk)
//    }
}

// MARK: Store

extension AudioPlugin {
    static func storePlayMode(_ mode: PlayMode) {
        UserDefaults.standard.set(mode.rawValue, forKey: keyOfCurrentPlayMode)

        // Store mode as string for CloudKit
        NSUbiquitousKeyValueStore.default.set(mode.shortName, forKey: keyOfCurrentPlayMode)
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
    static let MetaWrapperDeletedNotification = Notification.Name("MetaWrapperDeletedNotification")
    static let MetaWrappersDeletedNotification = Notification.Name("MetaWrappersDeletedNotification")
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
