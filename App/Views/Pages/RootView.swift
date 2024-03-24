import SwiftUI

struct RootView<Content>: View where Content: View {
    private var content: Content
    private var fileManagerDelegate = MyFileManagerDelegate()
    private var noLaunchView = false
    
    @State private var snapshotImage: Image? = nil
    @State private var isReady: Bool = false
    @State private var errorMessage: String? = nil
    @State private var iCloudDocumentsUrl: URL? = nil
    @State private var databaseManager: DBManager? = nil
    @State private var audioManager: AudioManager? = nil
    @State private var mediaPlayerManger: MediaPlayerManager? = nil
    @State private var windowManager: WindowManager = WindowManager()
    @State private var appManager: AppManager = AppManager()
    @State private var playListManager: PlayListManager = PlayListManager()

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var target: some View {
        ZStack {
            BackgroundView.type2A

            if isReady {
                content
                    .environmentObject(audioManager!)
                    .environmentObject(databaseManager!)
                    .environmentObject(mediaPlayerManger!)
                    .environmentObject(windowManager)
                    .environmentObject(appManager)
                    .environmentObject(playListManager)
                #if os(macOS)
                    .frame(minWidth: 350, minHeight: AppManager.controlViewHeight)
                    .blendMode(.normal)
                #endif
            } else {
                LanuchView(errorMessage: errorMessage)
                    .onAppear {
                        AppConfig.logger.app.info("初始化环境变量")
                        AppManager.prepare({ result in
                            switch result {
                            case let .failure(error):
                                errorMessage = error.localizedDescription
                            case let .success(url):
                                databaseManager = DBManager(rootDir: url)
                                audioManager = AudioManager(databaseManager: databaseManager!)
                                mediaPlayerManger = MediaPlayerManager(audioManager: audioManager!)

                                #if os(iOS)
                                    UIApplication.shared.beginReceivingRemoteControlEvents()
                                #endif

                                FileManager.default.delegate = fileManagerDelegate
                                AppConfig.logger.app.info("初始化环境变量完成")

                                isReady = true
                            }
                        })
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

#Preview("ContentView") {
    RootView {
        ContentView(play: false)
    }
}

#Preview("自定义") {
    RootView {
        Text("HHHH")
    }
}
