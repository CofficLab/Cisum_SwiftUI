import OSLog
import SwiftUI

struct RootView<Content>: View where Content: View {
    private var content: Content
    private var verbose = true
    private var label: String { "\(Logger.isMain)🌳 RootView::" }

    var db = DB(Config.getContainer, reason: "RootView")
    var dbSynced = DBSynced(Config.getSyncedContainer)
    var appManager = AppManager()
    var storeManager = StoreManager()

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .frame(minWidth: Config.minWidth, minHeight: Config.minHeight)
            .blendMode(.normal)
            .task {
                if verbose {
                    os_log("\(self.label)同步数据库")
                }

                await db.startWatch()

                #if os(iOS)
                    UIApplication.shared.beginReceivingRemoteControlEvents()
                #endif
            }
            .task(priority: .background) {
                Config.bgQueue.asyncAfter(deadline: .now() + 0) {
                    if verbose {
                        os_log("\(self.label)执行后台任务")
                    }

                    Task.detached(priority: .background, operation: {
                        await db.prepareJob()
                    })

                    Task.detached(operation: {
                        self.onAppOpen()
                    })
                }
            }
            .background(Config.rootBackground)
            .environmentObject(db)
            .environmentObject(PlayManager(db: db))
            .environmentObject(appManager)
            .environmentObject(storeManager)
            .environmentObject(DiskManager())
    }

    func onAppOpen() {
        Task {
            let uuid = Config.getDeviceId()
            let audioCount = await db.getTotalOfAudio()

            await dbSynced.saveDeviceData(uuid: uuid, audioCount: audioCount)
        }
    }
}

#Preview("App") {
    AppPreview()
}
