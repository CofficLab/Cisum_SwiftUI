import SwiftUI
import Foundation
import OSLog

class BookApp: SuperLayout, SuperLog {
    let emoji = "📚"
    var id: String = "Book"

    var iconName: String = "books.vertical"
    
    var icon: any View {
        Image(systemName: iconName)
    }
    
    var layout: any View {
        BookLayout()
    }
    
    var poster: any View {
        BookPoster()
    }

    var title: String {
        "有声书模式"
    }

    var description: String {
        "适用于听有声书的场景"
    }

    init() {
        os_log("%@👻👻👻 init", t)
    }

    func getDisk() -> (any Disk)? {
        return nil
    }

    func boot() {
        os_log("%@👻👻👻 boot", t)
    }

    func setCurrent(url: URL) {
        os_log("\(self.t)👻👻👻 setCurrent: \(url.absoluteString)")
        
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
