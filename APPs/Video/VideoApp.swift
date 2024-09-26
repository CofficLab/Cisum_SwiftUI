import SwiftUI
import Foundation
import OSLog

class VideoApp: SuperLayout, SuperLog {
    var id = "Video"

    var iconName: String = "video"
    
    var icon: any View {
        Image(systemName: iconName)
    }
    
    var layout: any View {
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
    
    func getDisk() -> (any Disk)? {
        DiskiCloud.make("videos")
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
