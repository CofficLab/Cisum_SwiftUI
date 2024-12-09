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
            BookDB()
        )
    }

    func addPosterView() -> AnyView {
        return AnyView(
            BookPoster()
        )
    }

    func onPlay() {
        os_log("\(self.t)OnPlay")
    }

    func onPlayStateUpdate() {
        os_log("\(self.t)OnPlayStateUpdate")
    }

    func onPlayAssetUpdate() {
        os_log("\(self.t)OnPlayAssetUpdate")
    }

    func onInit() {
        os_log("\(self.t)OnInit")
    }

    func onAppear() {
        os_log("\(self.t)OnAppear")
    }

    func onDisappear() {
        os_log("\(self.t)OnDisappear")
    }
}
