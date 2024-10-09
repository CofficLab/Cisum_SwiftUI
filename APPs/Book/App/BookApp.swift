import Foundation
import MagicKit
import OSLog
import SwiftUI

class BookApp: SuperLayout, SuperLog, SuperThread {
    let id = "Book"
    let emoji = "📚"
    let title = "有声书模式"
    let dirName = "audios_book"
    let iconName = "books.vertical"
    let description = "适用于听有声书的场景"

    var icon: any View {
        Image(systemName: iconName)
    }

    var rootView: any View {
        BookRoot()
    }

    var poster: any View {
        BookPoster()
    }

    var disk: (any Disk)?

    func getDisk() -> (any Disk)? {
        disk
    }

    func boot() {
        let verbose = false
        self.bg.async {
            if verbose {
                os_log("%@👻👻👻 boot", self.t)
            }
            self.disk = DiskiCloud.make(self.dirName)
            self.watchDisk(reason: "BookApp.Boot")
            self.emitBoot()
        }
    }

    func setCurrent(url: URL) {
        let verbose = false
        
        if verbose {
            os_log("\(self.t)👻👻👻 setCurrent: \(url.lastPathComponent)")
        }

        // 将当前的url存储下来
        UserDefaults.standard.set(url.absoluteString, forKey: "currentAudioURL")

        // 通过iCloud key-value同步
        NSUbiquitousKeyValueStore.default.set(url.absoluteString, forKey: "currentAudioURL")
        NSUbiquitousKeyValueStore.default.synchronize()
    }

    func getCurrent() -> URL? {
        if let urlString = UserDefaults.standard.string(forKey: "currentAudioURL") {
            return URL(string: urlString)
        }
        return nil
    }

    func setCurrentPlayMode(mode: PlayMode) {
        UserDefaults.standard.set(mode.rawValue, forKey: "currentBookPlayMode")
    }

    func getCurrentPlayMode() -> PlayMode? {
        if let mode = UserDefaults.standard.string(forKey: "currentBookPlayMode") {
            return PlayMode(rawValue: mode)
        }
        return nil
    }

    func watchDisk(reason: String) {
        guard var disk = disk else {
            return
        }

        disk.onUpdated = { items in
            Task {
                await DB(Config.getContainer, reason: "DataManager.WatchDisk").bookSync(items)
            }
        }

        Task {
            await disk.watch(reason: reason)
        }
    }

    // MARK: 恢复上次播放的

    func restore(reason: String, verbose: Bool = true) {
        if verbose {
            os_log("\(self.t)👻👻👻 Restore because of \(reason)")
        }

//        playMan.mode = PlayMode(rawValue: Config.currentMode) ?? playMan.mode

//        Task {
//            let currentURL = await dbSynced.getSceneCurrent(data.appScene, reason: "Restore")
//
//            if let url = currentURL {
//                if verbose {
//                    os_log("\(t)上次播放 -> \(url.lastPathComponent)")
//                }
//
//                playMan.prepare(PlayAsset(url: url))
//            } else {
//                if verbose {
//                    os_log("\(t)无上次播放的音频，尝试播放第一个(\(data.disk.name))")
//                }
//
//                playMan.prepare(data.first())
//            }
//        }
    }
}

// MARK: Event

extension Notification.Name {
    static let BookAppDidBoot = Notification.Name("BookAppDidBoot")
}

extension BookApp {
    func emitBoot() {
        self.main.async {
            NotificationCenter.default.post(name: .BookAppDidBoot, object: nil)
        }
    }
}
