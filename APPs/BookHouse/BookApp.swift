import SwiftUI
import Foundation
import OSLog

class BookApp: SuperLayout, SuperLog {
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
