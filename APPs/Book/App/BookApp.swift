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
            os_log("\(self.t)SetCurrent: \(url.lastPathComponent)")
        }

        // 将当前的url存储下来
        UserDefaults.standard.set(url.absoluteString, forKey: "currentAudioURL")

        // 通过iCloud key-value同步
        NSUbiquitousKeyValueStore.default.set(url.absoluteString, forKey: "currentAudioURL")
        NSUbiquitousKeyValueStore.default.synchronize()
    }

    func getCurrent() -> URL? {
        let verbose = false

        if verbose {
            os_log("\(self.t)GetCurrent")
        }

        if let urlString = UserDefaults.standard.string(forKey: "currentAudioURL") {
            let url = URL(string: urlString)

            if verbose {
                os_log("  🎉 \(url?.lastPathComponent ?? "")")
            }

            return url
        }
        
        if verbose {
            os_log("  ➡️ No current book URL found")
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
