import Foundation
import MagicKit
import MagicPlayMan
import OSLog
import SwiftData
import SwiftUI

actor CopyPlugin: SuperPlugin, SuperLog {
    static let emoji = "🚛"

    let label: String = "Copy"
    let hasPoster: Bool = false
    let description: String = "作为歌曲仓库，只关注文件，文件夹将被忽略"
    let iconName: String = "music.note"
    let isGroup: Bool = false
    @MainActor var db: CopyDB? = nil
    @MainActor var worker: CopyWorker? = nil
    @MainActor var container: ModelContainer?

    @MainActor func addStateView(currentGroup: SuperPlugin?) -> AnyView? {
        guard let worker = self.worker else {
            return nil
        }

        guard let container = try? CopyConfig.getContainer() else {
            return nil
        }

        return AnyView(
            CopyStateView()
                .environmentObject(worker)
                .modelContainer(container)
        )
    }

    @MainActor func addRootView() -> AnyView? {
        guard let db = self.db else {
            return nil
        }

        guard let worker = self.worker else {
            return nil
        }

        guard let container = try? CopyConfig.getContainer() else {
            return nil
        }

        return AnyView(CopyRootView()
            .environmentObject(db)
            .environmentObject(worker)
            .modelContainer(container)
        )
    }

    @MainActor
    func onWillAppear(playMan: PlayManWrapper, currentGroup: (any SuperPlugin)?, storage: StorageLocation?) async throws {
        let verbose = false

        if verbose {
            os_log("\(self.a)")
        }

        let container = try CopyConfig.getContainer()
        let db = CopyDB(container, reason: self.author, verbose: false)

        self.container = container
        self.db = db
        self.worker = CopyWorker(db: db)
    }
}
