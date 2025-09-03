import Foundation
import MagicCore
import OSLog
import SwiftUI

actor BookPlugin: SuperPlugin, SuperLog {
    static let keyOfCurrentBookURL = "com.bookplugin.currentBookURL"
    static let keyOfCurrentBookTime = "com.bookplugin.currentBookTime"

    static let emoji = "🎺"
    let label: String = "Book"
    let hasPoster: Bool = true
    let description: String = "适用于听有声书的场景"
    let iconName: String = "book"
    let dirName = "audios_book"
    let isGroup: Bool = true

    @MainActor var disk: URL?
    @MainActor var bookDB: BookRepo?
    @MainActor var bookProvider: BookProvider?
    @MainActor var initialized = false

    @MainActor func addDBView(reason: String) -> AnyView? {
        guard let disk = disk else {
            return AnyView(BookPluginError.initialization(reason: "磁盘未就绪").makeView(title: "书籍数据库初始化失败"))
        }

        guard let bookDB = self.bookDB else {
            return AnyView(BookPluginError.initialization(reason: "BookDB 未找到").makeView(title: "书籍数据库初始化失败"))
        }

        guard let bookProvider = self.bookProvider else {
            return AnyView(BookPluginError.initialization(reason: "BookProvider 未找到").makeView(title: "书籍数据库初始化失败"))
        }
        
        os_log("\(self.t)生成DBView")

        return AnyView(
            BookDBView(verbose: true, disk: disk)
                .environmentObject(bookDB)
                .environmentObject(bookProvider)
        )
    }

    @MainActor
    func addPosterView() -> AnyView? { AnyView(BookPoster()) }

    @MainActor
    func onWillAppear(playMan: PlayManWrapper, currentGroup: (any SuperPlugin)?, storage: StorageLocation?) async throws {
        guard let currentGroup = currentGroup, currentGroup.label == self.label else {
            return
        }
        
        os_log("\(self.t)📺📺📺")
        if self.initialized {
            return
        }

        self.disk = Config.cloudDocumentsDir?.appendingFolder(self.dirName)
        self.bookDB = try BookRepo(disk: disk!, verbose: true)
        self.bookProvider = BookProvider(disk: disk!)
        self.initialized = true

        Task { @MainActor in
            if let url = BookPlugin.getCurrent(), let book = await self.bookDB?.find(url) {
                await playMan.play(book)

                if let time = BookPlugin.getCurrentTime() {
                    await playMan.seek(time: time)
                }
            } else {
                os_log("\(self.t)No current book URL")
            }
        }
    }

    func onPlayAssetUpdate(asset: PlayAsset?, currentGroup: SuperPlugin?) async throws {
        if currentGroup?.id != self.id {
            return
        }

        Self.storeCurrent(asset?.url)
        if let asset = asset, asset.url.isNotDownloaded {
            do {
                try await asset.url.download()
                os_log("\(self.t)onPlayAssetUpdate: 开始下载")
            } catch let e {
                os_log("\(self.t)onPlayAssetUpdate: \(e.localizedDescription)")

                assert(false, "BookPlugin: onPlayAssetUpdate: \(e.localizedDescription)")
            }
        }
    }

    func onPlayNext(playMan: PlayManWrapper, current: URL?, currentGroup: String?, verbose: Bool) async throws {
        if currentGroup != self.id {
            return
        }

        if let asset = current {
            let next = asset.getNextFile()

            if verbose {
                os_log("\(self.t)播放下一个 -> \(next?.title ?? "")")
            }

            if let next = next, let _ = await self.bookDB?.find(next) {
                await playMan.play(next)
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

#if os(macOS)
    #Preview("App - Large") {
        AppPreview()
            .frame(width: 600, height: 1000)
    }

    #Preview("App - Small") {
        AppPreview()
            .frame(width: 500, height: 800)
    }
#endif

#if os(iOS)
    #Preview("iPhone") {
        AppPreview()
    }
#endif
