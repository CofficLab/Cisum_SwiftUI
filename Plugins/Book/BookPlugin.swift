import Foundation
import MagicKit
import OSLog
import SwiftUI

class BookPlugin: SuperPlugin, SuperLog {
    static let keyOfCurrentBookURL = "com.bookplugin.currentBookURL"
    static let keyOfCurrentBookTime = "com.bookplugin.currentBookTime"

    static let emoji = "🎺"
    let label: String = "Book"
    let hasPoster: Bool = true
    let description: String = "适用于听有声书的场景"
    let iconName: String = "book"
    let dirName = "audios_book"
    let isGroup: Bool = true
    lazy var db = BookRecordDB(BookConfig.getContainer, reason: "BookPlugin")

    var disk: (any SuperStorage)?
    var bookDB: BookDB?
    var bookProvider: BookProvider?
    var initialized = false

    func addDBView(reason: String) -> AnyView {
        os_log("\(self.t)addDBView")

        guard let disk = disk else {
            return AnyView(EmptyView())
        }

        guard let bookDB = self.bookDB else {
            return AnyView(EmptyView())
        }
        
        guard let bookProvider = self.bookProvider else {
            return AnyView(EmptyView())
        }

        return AnyView(
            BookDBView(verbose: true, disk: disk)
                .environmentObject(bookDB)
                .environmentObject(bookProvider)
        )
    }
    
    func addStateView(currentGroup: SuperPlugin?) -> AnyView? {
        if currentGroup?.id != self.id {
            return nil
        }
        
        guard let bookProvider = self.bookProvider else {
            return nil
        }

        return AnyView(BookStateView().environmentObject(bookProvider))
    }

    func addPosterView() -> AnyView {
        return AnyView(
            BookPoster()
        )
    }
    
    func onWillAppear(playMan: PlayMan, currentGroup: SuperPlugin?, storage: StorageLocation?) {
        if currentGroup?.id != self.id {
            return
        }
        
        os_log("\(self.t)📺📺📺")
        if self.initialized {
            return
        }

        self.disk = CloudStorage.make(self.dirName, verbose: true, reason: self.className)
        self.bookDB = BookDB(db: self.db, disk: disk!, verbose: true)
        self.bookProvider = BookProvider(disk: disk!)
        self.initialized = true

        Task { @MainActor in
            if let url = BookPlugin.getCurrent(), let book = await self.bookDB?.find(url) {
                playMan.play(book.toPlayAsset(), reason: self.className, verbose: true)

                if let time = BookPlugin.getCurrentTime() {
                    playMan.seek(time)
                }
            } else {
                os_log("\(self.t)No current book URL")
            }
        }
    }

    func onPlay() {
    }

    func onPause(playMan: PlayMan) {
        Task { @MainActor in
            BookPlugin.storeCurrentTime(playMan.currentTime)
        }
    }

    func onPlayModeChange(mode: PlayMode) {

    }

    func onPlayAssetUpdate(asset: PlayAsset?, currentGroup: SuperPlugin?) async throws {
        if currentGroup?.id != self.id {
            return
        }

        Self.storeCurrent(asset?.url)
        if let asset = asset, asset.isNotDownloaded {
            do {
                try await asset.download()
                os_log("\(self.t)onPlayAssetUpdate: 开始下载")
            } catch let e {
                os_log("\(self.t)onPlayAssetUpdate: \(e.localizedDescription)")

                assert(false, "BookPlugin: onPlayAssetUpdate: \(e.localizedDescription)")
            }
        }
    }

    func onPlayNext(playMan: PlayMan, current: PlayAsset?, currentGroup: SuperPlugin?, verbose: Bool) async throws {
        if currentGroup?.id != self.id {
            return
        }

        if let asset = current {
            let next = asset.url.getNextFile()

            if verbose {
                os_log("\(self.t)播放下一个 -> \(next?.lastPathComponent ?? "")")
            }

            if let next = next, let book = await self.bookDB?.find(next) {
                await playMan.play(book.toPlayAsset(), reason: "onPlayNext", verbose: true)
            }
        }
    }

    func onPlayPrev(playMan: PlayMan, current: PlayAsset?, currentGroup: SuperPlugin?, verbose: Bool) async throws {
        if currentGroup?.id != self.id {
            return
        }
    }
}

// MARK: Store

extension BookPlugin {
    static func storeCurrent(_ url: URL?) {
        UserDefaults.standard.set(url, forKey: keyOfCurrentBookURL)

        // Store URL as string for CloudKit
        NSUbiquitousKeyValueStore.default.set(url?.absoluteString ?? "", forKey: keyOfCurrentBookURL)
        NSUbiquitousKeyValueStore.default.synchronize()
    }

    static func storeCurrentTime(_ time: TimeInterval) {
        UserDefaults.standard.set(time, forKey: keyOfCurrentBookTime)

        // Store time as string for CloudKit
        NSUbiquitousKeyValueStore.default.set(String(time), forKey: keyOfCurrentBookTime)
        NSUbiquitousKeyValueStore.default.synchronize()
    }

    static func getCurrent() -> URL? {
        // First, try to get the URL from UserDefaults
        if let url = UserDefaults.standard.url(forKey: keyOfCurrentBookURL) {
            return url
        }

        // If not found in UserDefaults, try to get from iCloud
        if let urlString = NSUbiquitousKeyValueStore.default.string(forKey: keyOfCurrentBookURL),
           let url = URL(string: urlString) {
            // If found in iCloud, update UserDefaults for future local access
            UserDefaults.standard.set(url, forKey: keyOfCurrentBookURL)
            return url
        }

        return nil
    }

    static func getCurrentTime() -> TimeInterval? {
        // First, try to get the time from UserDefaults
        let time = UserDefaults.standard.double(forKey: keyOfCurrentBookTime)
        if time > 0 { // Since 0 is the default value when key doesn't exist
            return time
        }

        // If not found in UserDefaults, try to get from iCloud
        if let timeString = NSUbiquitousKeyValueStore.default.string(forKey: keyOfCurrentBookTime),
           let time = TimeInterval(timeString) {
            // If found in iCloud, update UserDefaults for future local access
            UserDefaults.standard.set(time, forKey: keyOfCurrentBookTime)
            return time
        }

        return nil
    }
}
