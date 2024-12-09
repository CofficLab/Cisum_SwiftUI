import Foundation
import MagicKit
import OSLog
import SwiftUI

class AudioPlugin: SuperPlugin, SuperLog {
    let emoji = "🎺"

    var label: String = "Audio"
    var hasPoster: Bool = true
    let description: String = "作为歌曲仓库，只关注文件，文件夹将被忽略"
    var iconName: String = "music.note"

    func addDBView() -> AnyView {
        os_log("\(self.t)AddDBView")

        return AnyView(
            AudioDB()
        )
    }

    func addPosterView() -> AnyView {
        return AnyView(
            AudioPoster()
        )
    }

    func addToolBarButtons() -> [(id: String, view: AnyView)] {
        return [
            (id: "like", view: AnyView(
                BtnLike(autoResize: false)
            ))
        ]
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

extension Notification.Name {
    static let AudiosUpdatedNotification = Notification.Name("AudiosUpdatedNotification")
    static let AudioUpdatedNotification = Notification.Name("AudioUpdatedNotification")
    static let SyncingNotification = Notification.Name("SyncingNotification")
    static let MetaWrapperDeletedNotification = Notification.Name("MetaWrapperDeletedNotification")
    static let MetaWrappersDeletedNotification = Notification.Name("MetaWrappersDeletedNotification")
}
