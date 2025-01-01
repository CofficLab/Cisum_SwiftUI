import Foundation
import MagicKit
import MagicUI
import OSLog
import SwiftUI
import MagicPlayMan

class CopyPlugin: SuperPlugin, SuperLog {
    static let emoji = "🚛"

    let label: String = "Copy"
    var hasPoster: Bool = false
    let description: String = "作为歌曲仓库，只关注文件，文件夹将被忽略"
    var iconName: String = "music.note"
    var isGroup: Bool = false
    var db: CopyDB?
    var worker: CopyWorker?

    func addStateView(currentGroup: SuperPlugin?) -> AnyView? {
        return AnyView(
            CopyStateView()
                .environmentObject(self.worker!)
                .modelContainer(CopyConfig.getContainer))
    }

    func addRootView() -> AnyView? {
        //os_log("\(self.t)🖥️🖥️🖥️ AddRootView")
        
        guard let db = self.db else {
            assert(false, "DB is nil")
            return nil
        }

        guard let worker = self.worker else {
            assert(false, "Worker is nil")
            return nil
        }

        return AnyView(CopyRootView()
            .environmentObject(db)
            .environmentObject(worker)
            .modelContainer(CopyConfig.getContainer)
        )
    }

    func onWillAppear(playMan: MagicPlayMan, currentGroup: (any SuperPlugin)?, storage: StorageLocation?) async {
        let verbose = false

        if verbose {
            os_log("\(self.a)")
        }

        self.db = CopyDB(CopyConfig.getContainer, reason: self.author, verbose: false)
        self.worker = CopyWorker(db: self.db!)
    }
}
