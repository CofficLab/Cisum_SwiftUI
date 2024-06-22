import OSLog
import SwiftUI

struct RootView<Content>: View where Content: View {
    private var content: Content
    private var verbose = true
    private var label: String { "\(Logger.isMain)🌳 RootView::" }

    var db: DB
    var dbSynced = DBSynced(Config.getSyncedContainer)
    var appManager = AppManager()
    var storeManager = StoreManager()
    var playMan: PlayMan
    var playManager: PlayManager
    var diskManager: DiskManager = DiskManager()

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
        self.db = DB(Config.getContainer, reason: "RootView")
        self.playMan = PlayMan()
        self.playManager = PlayManager(db: self.db, playMan: self.playMan)
    }

    var body: some View {
        content
            .onAppear {
                restore()
            }
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
            .environmentObject(playManager)
            .environmentObject(appManager)
            .environmentObject(storeManager)
            .environmentObject(diskManager)
    }

    func onAppOpen() {
        Task {
            let uuid = Config.getDeviceId()
            let audioCount = await db.getTotalOfAudio()

            await dbSynced.saveDeviceData(uuid: uuid, audioCount: audioCount)
        }
    }
    
    // MARK: 恢复上次播放的

    func restore(verbose: Bool = true) {
        if verbose {
            os_log("\(self.label)试着恢复上次播放的音频")
        }

        playManager.mode = PlayMode(rawValue: Config.currentMode) ?? playManager.mode
        
        if let currentAudioId = Config.currentAudio {
            if verbose {
                os_log("\(self.label)上次播放的音频是 -> \(currentAudioId.lastPathComponent)")
            }
            
            Task {
                if let currentAudio = await self.db.findAudio(currentAudioId) {
                    playMan.prepare(currentAudio.toPlayAsset())
                } else if let current = await self.db.first() {
                    playMan.prepare(current.toPlayAsset())
                } else {
                    os_log("\(self.label)restore nothing to play")
                }
            }
        } else {
            if verbose {
                os_log("\(self.label)无上次播放的音频")
            }
        }
    }
}

#Preview("App") {
    AppPreview()
}
