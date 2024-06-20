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
        ZStack {
            Config.rootBackground

            content
                .environmentObject(PlayManager(db: db))
                .environmentObject(appManager)
                .environmentObject(storeManager)
                .environmentObject(db)
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
                // 等content出现后，再执行后台任务
                .task(priority: .background) {
                    Config.bgQueue.asyncAfter(deadline: .now() + 0) {
                        if verbose {
                            os_log("\(self.label)执行后台任务")
                        }

//                        Task.detached(priority: .background, operation: {
//                            await db.prepareJob()
//                        })
//
//                        Task.detached(operation: {
//                            self.onAppOpen()
//                        })
                    }
                }
        }
    }

    /// 执行并输出耗时
    func printRunTime(_ title: String, tolerance: Double = 1, verbose: Bool = false, _ code: () -> Void) {
        if verbose {
            os_log("\(label)\(title)")
        }

        let startTime = DispatchTime.now()

        code()

        // 计算代码执行时间
        let nanoTime = DispatchTime.now().uptimeNanoseconds - startTime.uptimeNanoseconds
        let timeInterval = Double(nanoTime) / 1000000000

        if verbose && timeInterval > tolerance {
            os_log("\(label)\(title) cost \(timeInterval) 秒 🐢🐢🐢")
        }
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
