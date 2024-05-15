import OSLog
import SwiftUI

struct RootView<Content>: View where Content: View {
    private var content: Content
    private var verbose = true
    private var label = "🌳 RootView::"

    @State private var isReady: Bool = false
    @State private var errorMessage: String? = nil
    @State private var audioManager: AudioManager? = nil
    @State private var mediaPlayerManger: MediaPlayerManager? = nil
    @State private var windowManager: WindowManager = .init()
    @State private var appManager: AppManager = .init()

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            AppConfig.rootBackground

            if isReady {
                content
                    .environmentObject(audioManager!)
                    .environmentObject(mediaPlayerManger!)
                    .environmentObject(windowManager)
                    .environmentObject(appManager)
                    .frame(minWidth: AppConfig.minWidth, minHeight: AppConfig.minHeight)
                    .blendMode(.normal)
            } else {
                LanuchView(errorMessage: errorMessage)
            }
        }
        .task(priority: .high) {
            if verbose {
                os_log("\(Logger.isMain)\(self.label)初始化")
            }

            self.audioManager = AudioManager()
            self.mediaPlayerManger = MediaPlayerManager(audioManager: audioManager!)
            self.isReady = true

            #if os(iOS)
                UIApplication.shared.beginReceivingRemoteControlEvents()
            #endif

            if verbose {
                os_log("\(Logger.isMain)\(self.label)准备数据库")
            }
            
            Task.detached(priority: .high, operation: {
                let db = DB(AppConfig.getContainer())
                await db.startWatch()
            })
            
            Task.detached(priority: .background, operation: {
                let db = DB(AppConfig.getContainer())
                await db.prepareJob()
            })
            
            Task.detached(priority: .background, operation: {
                let db = DB(AppConfig.getContainer())
                await db.runDeleteInvalidJob()
            })
            
            Task.detached(priority: .background, operation: {
                let db = DB(AppConfig.getContainer())
                await db.runGetCoversJob()
            })
            
//            Task.detached(priority: .background, operation: {
//                let db = DB(AppConfig.getContainer())
//                await db.runFindAudioGroupJob()
//            })
        }
    }
}

#Preview("App") {
    RootView {
        ContentView()
    }
    .modelContainer(AppConfig.getContainer())
}
