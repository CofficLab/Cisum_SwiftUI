import OSLog
import SwiftData
import SwiftUI

struct RootView<Content>: View where Content: View {
    private var content: Content
    
    @Environment(\.modelContext) var context: ModelContext

    @State private var isReady: Bool = false
    @State private var errorMessage: String? = nil
    @State private var audioManager: AudioManager? = nil
    @State private var db: DB? = nil
    @State private var mediaPlayerManger: MediaPlayerManager? = nil
    @State private var windowManager: WindowManager = WindowManager()
    @State private var appManager: AppManager = AppManager()

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            BackgroundView.type2A

            if isReady {
                content
                    .environmentObject(audioManager!)
                    .environmentObject(mediaPlayerManger!)
                    .environmentObject(windowManager)
                    .environmentObject(appManager)
                #if os(macOS)
                    .frame(minWidth: 350, minHeight: AppConfig.controlViewHeight)
                    .blendMode(.normal)
                #endif
            } else {
                LanuchView(errorMessage: errorMessage)
                    .onAppear {
                        os_log("\(Logger.isMain)🚩 初始化环境变量")
                        audioManager = AudioManager()
                        db = DB(context: context)
                        mediaPlayerManger = MediaPlayerManager(audioManager: audioManager!)

                        #if os(iOS)
                            UIApplication.shared.beginReceivingRemoteControlEvents()
                        #endif

                        isReady = true
                    }
            }
        }
    }
}

#Preview("App") {
    RootView {
        ContentView()
    }
}
