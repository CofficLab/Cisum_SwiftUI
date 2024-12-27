import SwiftUI
import Foundation
import OSLog
import MagicKit
import MagicUI

class VideoApp: SuperLog {
    static let emoji = "🎥"
    var id = "Video"

    var iconName: String = "video"
    
    var icon: any View {
        Image(systemName: iconName)
    }
    
    var rootView: any View {
        VideoLayout()
    }
    
    var poster: any View {
        Text("Video")
    }

    var title: String {
        "视频模式"
    }

    var description: String {
        "适用于看视频的场景"
    }

    init() {
        os_log("%@👻👻👻 init", t)
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
        UserDefaults.standard.set(mode.rawValue, forKey: "currentVideoPlayMode")
    }

    func getCurrentPlayMode() -> PlayMode? {
        if let mode = UserDefaults.standard.string(forKey: "currentVideoPlayMode") {
            return PlayMode(rawValue: mode)
        }
        return nil
    }

    func boot() {
        os_log("%@👻👻👻 boot", t)
    }
    
    func getDisk() -> (any SuperStorage)? {
        CloudStorage.make("videos", verbose: true, reason: "VideoApp")
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
