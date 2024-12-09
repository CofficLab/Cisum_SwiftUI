import Foundation
import MagicKit
import OSLog
import SwiftUI

class AudioPlugin: SuperPlugin, SuperLog {
    static let keyOfCurrentAudioURL = "AudioPluginCurrentAudioURL"

    let emoji = "🎺"
    let label: String = "Audio"
    var hasPoster: Bool = true
    let description: String = "作为歌曲仓库，只关注文件，文件夹将被忽略"
    var iconName: String = "music.note"
    var isGroup: Bool = true

    func addDBView() -> AnyView {
        os_log("\(self.t)AddDBView")

        return AnyView(
            AudioDB()
        )
    }

    func addPosterView() -> AnyView {
        return AnyView(
            AudioPoster()
        )
    }

    func addToolBarButtons() -> [(id: String, view: AnyView)] {
        return [
            (id: "like", view: AnyView(
                BtnLike(autoResize: false)
            )),
        ]
    }

    func onPlay() {
        os_log("\(self.t)OnPlay")
    }

    func onPlayStateUpdate() {
        os_log("\(self.t)OnPlayStateUpdate")
    }

    func onPlayAssetUpdate(asset: PlayAsset?) {
        os_log("\(self.t)OnPlayAssetUpdate, store current audio URL -> \(asset?.url.lastPathComponent ?? "nil")")
        AudioPlugin.storeCurrent(asset?.url)
    }

    func onInit() {
        os_log("\(self.t)OnInit")
    }

    func onAppear(playMan: PlayMan, currentGroup: SuperPlugin?) {
        os_log("\(self.t)OnAppear")

        if currentGroup?.id != self.id {
            return
        }

        if let url = AudioPlugin.getCurrent() {
            try? playMan.play(PlayAsset(url: url), reason: "OnAppear", verbose: true)
        } else {
            os_log("\(self.t)No current audio URL")
        }
    }

    func onDisappear() {
        os_log("\(self.t)OnDisappear")
    }
    
    static func storeCurrent(_ url: URL?) {
        UserDefaults.standard.set(url, forKey: keyOfCurrentAudioURL)

        // Store URL as string for CloudKit
        NSUbiquitousKeyValueStore.default.set(url?.absoluteString ?? "", forKey: keyOfCurrentAudioURL)
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
}

extension Notification.Name {
    static let AudiosUpdatedNotification = Notification.Name("AudiosUpdatedNotification")
    static let AudioUpdatedNotification = Notification.Name("AudioUpdatedNotification")
    static let SyncingNotification = Notification.Name("SyncingNotification")
    static let MetaWrapperDeletedNotification = Notification.Name("MetaWrapperDeletedNotification")
    static let MetaWrappersDeletedNotification = Notification.Name("MetaWrappersDeletedNotification")
}
