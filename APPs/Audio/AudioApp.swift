import Foundation
import OSLog
import SwiftUI

class AudioApp: SuperLayout, SuperLog {
    let emoji = "🎶"
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

    init() {
        os_log("%@👻👻👻 init", t)
    }

    func boot() {
        os_log("%@👻👻👻 boot", t)

        self.disk = DiskiCloud.make("audios")

        Task {
            self.watchDisk(reason: r("AudioApp.init"))
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
        os_log("\(self.t)👻👻👻 getCurrent")
        
        if let urlString = UserDefaults.standard.string(forKey: "currentAudioURL") {
            return URL(string: urlString)
        }
        
        return nil
    }
}
