import Foundation
import OSLog
import SwiftUI
import MagicKit

class AudioApp: SuperLayout, SuperLog, SuperThread {
    let emoji = "🎶"
    let dirName = "audios"
    var id: String = "Audio"

    var iconName: String = "music.note.list"

    var icon: any View {
        Image(systemName: iconName)
    }

    var layout: any View {
        AudioLayout()
    }

    var poster: any View {
        AudioPoster()
    }

    var title = "歌曲模式"

    var description: String = "作为歌曲仓库，只关注文件，文件夹将被忽略"

    var disk: (any Disk)?

    func boot() {
        self.bg.async {
            os_log("%@👻👻👻 boot", self.t)
            self.disk = DiskiCloud.make(self.dirName)
            self.watchDisk(reason: self.r("AudioApp.Boot"))
            self.emitBoot()
        }
    }

    func getDisk() -> (any Disk)? {
        return disk
    }

    func watchDisk(reason: String) {
        guard var disk = disk else {
            return
        }

        disk.onUpdated = { items in
//            DispatchQueue.main.async {
//                self.updating = items
//            }

            Task {
                await DB(Config.getContainer, reason: "DataManager.WatchDisk").sync(items)
            }
        }

       Task {
           await disk.watch(reason: reason)
       }
    }

    func setCurrent(url: URL) {
        let verbose = false
        if verbose {
            os_log("\(self.t)👻👻👻 setCurrent: \(url.absoluteString)")
        }
        
        // 将当前的url存储下来
        UserDefaults.standard.set(url.absoluteString, forKey: "currentAudioURL")
        
        // 通过iCloud key-value同步
        NSUbiquitousKeyValueStore.default.set(url.absoluteString, forKey: "currentAudioURL")
        NSUbiquitousKeyValueStore.default.synchronize()
    }

    func getCurrent() -> URL? {
        os_log("\(self.t)GetCurrent")
        
        if let urlString = UserDefaults.standard.string(forKey: "currentAudioURL") {
            return URL(string: urlString)
        }
        
        return nil
    }
}

// MARK: Event 

extension Notification.Name {
    static let AudioAppDidBoot = Notification.Name("AudioAppDidBoot")
}

extension AudioApp {
    func emitBoot() {
        self.main.async {
            NotificationCenter.default.post(name: .AudioAppDidBoot, object: nil)
        }
    }
}