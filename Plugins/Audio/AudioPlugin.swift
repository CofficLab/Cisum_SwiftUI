import Foundation
import MagicKit
import OSLog
import SwiftUI

class AudioPlugin: SuperPlugin, SuperLog {
    static let keyOfCurrentAudioURL = "AudioPluginCurrentAudioURL"
    static let keyOfCurrentAudioTime = "AudioPluginCurrentAudioTime"
    static let keyOfCurrentPlayMode = "AudioPluginCurrentPlayMode"
    let emoji = "🎺"
    let dirName = "audios"
    let label: String = "Audio"
    var hasPoster: Bool = true
    let description: String = "作为歌曲仓库，只关注文件，文件夹将被忽略"
    var iconName: String = "music.note"
    var isGroup: Bool = true
    lazy var db = AudioRecordDB(AudioConfig.getContainer, reason: "AudioPlugin")

    var disk: (any SuperDisk)?
    var audioProvider: AudioProvider?
    var audioDB: AudioDB?

    func addDBView(reason: String) -> AnyView {
        guard let disk = self.disk else {
            return AnyView(EmptyView())
        }

        guard let audioProvider = self.audioProvider else {
            return AnyView(EmptyView())
        }
        
        guard let audioDB = audioDB else {
            return AnyView(EmptyView())
        }

        return AnyView(AudioDBView(verbose: false, reason: reason)
            .environmentObject(audioDB)
            .environmentObject(audioProvider)
        )
    }

    func addPosterView() -> AnyView {
        AnyView(AudioPoster())
    }

    func addSettingView() -> AnyView? {
        guard let audioProvider = self.audioProvider else {
            return nil
        }

        return AnyView(AudioSettings().environmentObject(audioProvider))
    }

    func addStateView(currentGroup: SuperPlugin?) -> AnyView? {
        if currentGroup?.id != self.id {
            return nil
        }
        
        guard let audioProvider = self.audioProvider else {
            return nil
        }

        return AnyView(AudioStateView().environmentObject(audioProvider))
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
        self.audioDB = AudioDB(db: self.db, disk: disk!)
        self.audioProvider = AudioProvider(disk: disk!)
    }

    func onPause(playMan: PlayMan) {
        Task { @MainActor in
            AudioPlugin.storeCurrentTime(playMan.currentTime)
        }
    }

    func onPlay() {
    }

    func onPlayAssetUpdate(asset: PlayAsset?, currentGroup: SuperPlugin?) async throws {
        if currentGroup?.id != self.id {
            return
        }

        AudioPlugin.storeCurrent(asset?.url)
        if let asset = asset, asset.isNotDownloaded {
            do {
                try await asset.download()
                os_log("\(self.t)onPlayAssetUpdate: 开始下载")
            } catch let e {
                os_log("\(self.t)onPlayAssetUpdate: \(e.localizedDescription)")
            }
        }
    }

    func onPlayModeChange(mode: PlayMode, asset: PlayAsset?) throws {
        AudioPlugin.storePlayMode(mode)
        
        // Use weak self to avoid retain cycles
        Task { [weak self] in
            guard let self = self else { return }
            
            switch mode {
            case .Loop:
                break
            case .Order:
                await self.db.sort(asset?.url, reason: self.className + ".OnPlayModeChange")
            case .Random:
                try await self.db.sortRandom(asset?.url, reason: self.className + ".OnPlayModeChange", verbose: true)
            }
        }
    }

    func onAppear(playMan: PlayMan, currentGroup: SuperPlugin?) {
        if currentGroup?.id != self.id {
            return
        }
        
        os_log("\(self.t)onAppear")

        let mode = AudioPlugin.getPlayMode()
        if let mode = mode {
            playMan.setMode(mode, reason: self.className + ".OnAppear")
        }

        Task { @MainActor in
            if let url = AudioPlugin.getCurrent(), let audio = await self.audioDB?.find(url) {
                playMan.play(audio.toPlayAsset(), reason: self.className + ".OnAppear", verbose: true)

                if let time = AudioPlugin.getCurrentTime() {
                    playMan.seek(time)
                }
            } else {
                os_log("\(self.t)No current audio URL")
            }
        }
    }

    func onPlayPrev(playMan: PlayMan, current: PlayAsset?, currentGroup: SuperPlugin?, verbose: Bool) async throws {
        os_log("\(self.t)OnPlayPrev")
        let asset = try await self.db.getPrevOf(current?.url, verbose: false)
        
        if let asset = asset {
            await playMan.play(PlayAsset(url: asset.url), reason: "OnPlayPrev", verbose: true)
        } else {
            throw AudioPluginError.NoPrevAsset
        }
    }

    func onPlayNext(playMan: PlayMan, current: PlayAsset?, currentGroup: SuperPlugin?, verbose: Bool) async throws {
        if currentGroup?.id != self.id {
            return
        }
        
        let mode = playMan.mode
        
        if verbose {
            os_log("\(self.t)OnPlayNext with mode \(mode.description)")
        }

        let asset = try await self.db.getNextOf(current?.url, verbose: false)
        if let asset = asset {
            await playMan.play(PlayAsset(url: asset.url), reason: "OnPlayNext", verbose: true)
        } else {
            throw AudioPluginError.NoNextAsset
        }
    }
}

// MARK: Store

extension AudioPlugin {
    static func storePlayMode(_ mode: PlayMode) {
        UserDefaults.standard.set(mode.rawValue, forKey: keyOfCurrentPlayMode)

        // Store mode as string for CloudKit
        NSUbiquitousKeyValueStore.default.set(mode.description, forKey: keyOfCurrentPlayMode)
        NSUbiquitousKeyValueStore.default.synchronize()
    }

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

    var errorDescription: String? {
        switch self {
        case .NoNextAsset:
            return "No next asset"
        case .NoPrevAsset:
            return "No prev asset"
        }
    }
}
