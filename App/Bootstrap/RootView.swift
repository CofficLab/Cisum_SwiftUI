import OSLog
import SwiftUI

struct RootView<Content>: View where Content: View {
    private var content: Content
    private var noLaunchView = false

    @State private var snapshotImage: Image? = nil
    @State private var isReady: Bool = false
    @State private var errorMessage: String? = nil
    @State private var iCloudDocumentsUrl: URL? = nil
    @State private var audioManager: AudioManager? = nil
    @State private var mediaPlayerManger: MediaPlayerManager? = nil
    @State private var windowManager: WindowManager = WindowManager()
    @State private var appManager: AppManager = AppManager()

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var target: some View {
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

                        #if os(iOS)
                            UIApplication.shared.beginReceivingRemoteControlEvents()
                        #endif

                        os_log("\(Logger.isMain)🚩 RootView::初始化环境变量完成")

                        isReady = true
                    }
            }
        }
    }

    var body: some View {
        VStack {
            #if os(macOS)
                //            Button("Snapshot", action: {
                //                snapshotImage = Image(ImageRenderer(content: target).cgImage!, scale: 1, label: Text("Snapshot"))
                //                ImageHelper.toJpeg(image: ImageRenderer(content: target).nsImage!)
                //            })
                //
                //            ZStack {
                //                snapshotImage
                //            }.background(.red.opacity(0.3)).border(.blue)
            #endif

            target
        }
    }
}

#Preview("App") {
    RootView {
        ContentView()
    }
}

#Preview("自定义") {
    RootView {
        Text("HHHH")
    }
}
