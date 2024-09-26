import SwiftUI
import Foundation
import OSLog

class AudioApp: SuperLayout, SuperLog {
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
    
    func getDisk() -> (any Disk)? {
        DiskiCloud.make("audios")
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
