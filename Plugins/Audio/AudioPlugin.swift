import Foundation
import MagicKit
import OSLog
import SwiftUI

class AudioPlugin: SuperPlugin, SuperLog {
    static let keyOfCurrentAudioURL = "AudioPluginCurrentAudioURL"
    static let keyOfCurrentAudioTime = "AudioPluginCurrentAudioTime"

    let emoji = "🎺"
    let dirName = "audios"
    let label: String = "Audio"
    var hasPoster: Bool = true
    let description: String = "作为歌曲仓库，只关注文件，文件夹将被忽略"
    var iconName: String = "music.note"
    var isGroup: Bool = true
    lazy var db = RecordDB(AudioConfig.getContainer, reason: "AudioPlugin")

    var disk: (any SuperDisk)?

    func addDBView() -> AnyView {
        guard let disk = self.disk else {
            return AnyView(EmptyView())
        }
        
        let fileDB = AudioDB(db: self.db, disk: disk)
        
        return AnyView(AudioDBView()
            .environmentObject(fileDB)
        )
    }

    func addPosterView() -> AnyView {
        AnyView(AudioPoster())
    }

    func addToolBarButtons() -> [(id: String, view: AnyView)] {
        return [
            (id: "like", view: AnyView(
                BtnLike(autoResize: false)
            )),
        ]
    }

    func onInit() {
        os_log("\(self.t)onInit")
        self.disk = DiskiCloud.make(self.dirName, verbose: true, reason: "AudioPlugin.onInit")
    }

    func onPause(playMan: PlayMan) {
        Task { @MainActor in
            AudioPlugin.storeCurrentTime(playMan.currentTime)
        }
    }

    func onPlay() {
    }

    func onPlayAssetUpdate(asset: PlayAsset?) {
        AudioPlugin.storeCurrent(asset?.url)
    }

    func onAppear(playMan: PlayMan, currentGroup: SuperPlugin?) {
        if currentGroup?.id != self.id {
            return
        }

        Task { @MainActor in
            if let url = AudioPlugin.getCurrent() {
                try? playMan.play(PlayAsset(url: url), reason: "OnAppear", verbose: true)

                if let time = AudioPlugin.getCurrentTime() {
                    playMan.seek(time)
                }
            } else {
                os_log("\(self.t)No current audio URL")
            }
        }

        self.watchDisk(reason: "AudioApp.Boot")
    }

    func onPlayPrev(playMan: PlayMan, current: PlayAsset?) async throws {
        os_log("\(self.t)OnPlayPrev")
        let asset = await self.db.getPrevOf(current?.url, verbose: false)
        if let asset = asset {
            try await playMan.play(PlayAsset(url: asset.url), reason: "OnPlayPrev", verbose: true)
        } else {
            throw AudioPluginError.NoPrevAsset
        }
    }

    func onPlayNext(playMan: PlayMan, current: PlayAsset?) async throws {
        os_log("\(self.t)OnPlayNext")
        let asset = await self.db.getNextOf(current?.url, verbose: false)
        if let asset = asset {
            try await playMan.play(PlayAsset(url: asset.url), reason: "OnPlayNext", verbose: true)
        } else {
            throw AudioPluginError.NoNextAsset
        }
    }

    func onPlayAssetDeleted(asset: PlayAsset) {
        os_log("\(self.t)OnPlayAssetDeleted")

        self.disk?.deleteFile(asset.url)
    }

    func watchDisk(reason: String) {
        guard var disk = disk else {
            return
        }

        disk.onUpdated = { items in
            Task {
                await self.db.sync(items)
            }
        }

        Task {
            await disk.watch(reason: reason, verbose: true)
        }
    }
}

// MARK: Store

extension AudioPlugin {
    static func storeCurrent(_ url: URL?) {
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

    var errorDescription: String? {
        switch self {
        case .NoNextAsset:
            return "No next asset"
        case .NoPrevAsset:
            return "No prev asset"
        }
    }
}
