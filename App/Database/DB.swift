import Foundation
import OSLog
import SwiftData
import SwiftUI

/**
 DB 负责
 - 对接文件系统
 - 提供 Audio
 - 操作 Audio
 */
actor DB: ModelActor {
    let modelContainer: ModelContainer
    let modelExecutor: any ModelExecutor

    var fileManager = FileManager.default
    var cloudHandler = CloudHandler()
    var bg = AppConfig.bgQueue
    var audiosDir: URL = AppConfig.audiosDir
    var handler = CloudHandler()
    var context: ModelContext

    init(_ container: ModelContainer) {
        os_log("\(Logger.isMain)🚩 初始化 DB")

        modelContainer = container
        context = ModelContext(container)
        context.autosaveEnabled = false
        modelExecutor = DefaultSerialModelExecutor(
            modelContext: context
        )

        Task {
            await getAudios()
        }
    }
}

#Preview {
    RootView {
        ContentView()
    }
}
