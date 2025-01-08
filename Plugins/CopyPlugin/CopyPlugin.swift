import Foundation
import MagicKit
import MagicUI
import OSLog
import SwiftUI
import MagicPlayMan

actor CopyPlugin: SuperPlugin, SuperLog {
    static let emoji = "🚛"

    let label: String = "Copy"
    let hasPoster: Bool = false
    let description: String = "作为歌曲仓库，只关注文件，文件夹将被忽略"
    let iconName: String = "music.note"
    let isGroup: Bool = false
    var db: CopyDB? = nil
    let worker: CopyWorker? = nil

    @MainActor func addStateView(currentGroup: SuperPlugin?) -> AnyView? {
        return nil
//        return AnyView(
//            CopyStateView()
//                .environmentObject(self.worker!)
//                .modelContainer(CopyConfig.getContainer))
    }

    @MainActor func addRootView() -> AnyView? {
        //os_log("\(self.t)🖥️🖥️🖥️ AddRootView")
        nil
//        guard let db = self.db else {
//            assert(false, "DB is nil")
//            return nil
//        }
//
//        guard let worker = self.worker else {
//            assert(false, "Worker is nil")
//            return nil
//        }
//
//        return AnyView(CopyRootView()
//            .environmentObject(db)
//            .environmentObject(worker)
//            .modelContainer(CopyConfig.getContainer)
//        )
    }

    func onWillAppear(playMan: PlayManWrapper, currentGroup: (any SuperPlugin)?, storage: StorageLocation?) async {
        let verbose = false

        if verbose {
            os_log("\(self.a)")
        }

//        self.db = await CopyDB(CopyConfig.getContainer, reason: self.author, verbose: false)
//        self.worker = await CopyWorker(db: self.db!)
    }
}
