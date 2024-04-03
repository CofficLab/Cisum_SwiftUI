import OSLog
import SwiftUI

struct RootView<Content>: View where Content: View {
    private var content: Content

    @Environment(\.modelContext) private var modelContext

    @State private var isReady: Bool = false
    @State private var errorMessage: String? = nil
    @State private var audioManager: AudioManager? = nil
    @State private var mediaPlayerManger: MediaPlayerManager? = nil
    @State private var windowManager: WindowManager = .init()
    @State private var appManager: AppManager = .init()
    @State private var db: DB? = nil

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
                        mediaPlayerManger = MediaPlayerManager(audioManager: audioManager!)
                        self.db = DB(modelContext)

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
