import Foundation
import MagicKit
import OSLog
import SwiftUI

class CopyPlugin: SuperPlugin, SuperLog {
    static let emoji = "🚛"

    let label: String = "Copy"
    var hasPoster: Bool = false
    let description: String = "作为歌曲仓库，只关注文件，文件夹将被忽略"
    var iconName: String = "music.note"
    var isGroup: Bool = false
    var db: CopyDB?
    var worker: CopyWorker?

    init() {
        os_log("\(self.i)")
    }

    func addStateView(currentGroup: SuperPlugin?) -> AnyView? {
        return AnyView(
            CopyStateView()
                .environmentObject(self.worker!)
                .modelContainer(CopyConfig.getContainer))
    }

    func addRootView() -> AnyView? {
        os_log("\(self.t)🖥️🖥️🖥️ AddRootView")
        
        guard let db = self.db else {
            assert(false, "DB is nil")
        }

        guard let worker = self.worker else {
            assert(false, "Worker is nil")
        }

        return AnyView(CopyRootView()
            .environmentObject(db)
            .environmentObject(worker)
            .modelContainer(CopyConfig.getContainer)
        )
    }

    func addStatusView() -> AnyView? {
        os_log("\(self.t)🖥️🖥️🖥️ AddStatusView")

        return AnyView(CopyStatusView()
            .modelContainer(CopyConfig.getContainer))
    }

    func onInit(storage: StorageLocation?) {
        os_log("\(self.t)🛫🛫🛫 OnInit")

        self.db = CopyDB(CopyConfig.getContainer, reason: self.author + ".onInit", verbose: true)
        self.worker = CopyWorker(db: self.db!)
    }
}
