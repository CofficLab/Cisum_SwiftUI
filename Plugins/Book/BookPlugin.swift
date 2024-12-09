import Foundation
import MagicKit
import OSLog
import SwiftUI

class BookPlugin: SuperPlugin, SuperLog {    
    let emoji = "🎺"

    var label: String = "Book"
    var hasPoster: Bool = true
    let description: String = "适用于听有声书的场景"
    var iconName: String = "book"
    
    func addDBView() -> AnyView {
        os_log("\(self.t)AddDBView")

        return AnyView(
            EmptyView()
        )
    }

    func addPosterView() -> AnyView {
        return AnyView(
            BookPoster()
        )
    }

    func onInit() {
    }

    func onAppear(playMan: PlayMan, currentGroup: SuperPlugin?) {
    }

    func onPlay() {
    }
    
    func onPause(playMan: PlayMan) {
        
    }

    func onPlayAssetUpdate(asset: PlayAsset?) {
    }

    func onPlayNext(playMan: PlayMan, current: PlayAsset?) throws {
    }

    func onPlayPrev(playMan: PlayMan, current: PlayAsset?) throws {
    }
}
