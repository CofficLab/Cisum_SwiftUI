import OSLog
import SwiftUI

struct RootView<Content>: View where Content: View {
    private var content: Content
    private var verbose = false

    @State private var isReady: Bool = false
    @State private var errorMessage: String? = nil
    @State private var audioManager: AudioManager? = nil
    @State private var mediaPlayerManger: MediaPlayerManager? = nil
    @State private var windowManager: WindowManager = WindowManager()
    @State private var appManager: AppManager = AppManager()

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
                    .onAppear {
                        if verbose {
                            os_log("\(Logger.isMain)🚩 初始化环境变量")
                        }
                        
                        audioManager = AudioManager()
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
    .modelContainer(AppConfig.getContainer())
}
