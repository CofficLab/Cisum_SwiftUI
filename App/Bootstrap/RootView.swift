import OSLog
import SwiftUI

struct RootView<Content>: View where Content: View {
    private var content: Content
    private var verbose = true
    private var label: String {
        "\(Logger.isMain)🌳 RootView::"
    }

    @State private var isReady: Bool = false
    @State private var errorMessage: String? = nil
    @State private var audioManager: AudioManager? = nil
    @State private var appManager: AppManager? = nil

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            AppConfig.rootBackground

            if isReady {
                content
                    .environmentObject(audioManager!)
                    .environmentObject(appManager!)
                    .frame(minWidth: AppConfig.minWidth, minHeight: AppConfig.minHeight)
                    .blendMode(.normal)
                    .task {
                        if verbose {
                            os_log("\(self.label)同步数据库")
                        }
                        await DB(AppConfig.getContainer).startWatch()

                        #if os(iOS)
                            UIApplication.shared.beginReceivingRemoteControlEvents()
                        #endif
                    }
                    // 等content出现后，再执行后台任务
                    .task(priority: .background) {
                        AppConfig.bgQueue.asyncAfter(deadline: .now() + 20) {
                            if verbose {
                                os_log("\(self.label)执行后台任务")
                            }

                            Task.detached(priority: .background, operation: {
                                await DB(AppConfig.getContainer).prepareJob()
                            })

                            Task.detached(priority: .background, operation: {
                                await DB(AppConfig.getContainer).runDeleteInvalidJob()
                            })

                            Task.detached(priority: .background, operation: {
                                await DB(AppConfig.getContainer).runGetCoversJob()
                            })

                            Task.detached(priority: .background, operation: {
                                await DB(AppConfig.getContainer).runFindAudioGroupJob()
                            })
                        }
                    }
            } else {
                LanuchView(errorMessage: errorMessage)
                    // 如果用onAppear，onAppear里的内容执行完才出现视图
                    // 如果用task，则优先显示视图
                    .task {
                        os_log("\(self.label)初始化")
                        self.audioManager = AudioManager()
                        self.appManager = AppManager()
                        withAnimation(.none) {
                            self.isReady = true
                        }
                    }
            }
        }
    }

    /// 执行并输出耗时
    func printRunTime(_ title: String, tolerance: Double = 1, verbose: Bool = false, _ code: () -> Void) {
        if verbose {
            os_log("\(self.label)\(title)")
        }

        let startTime = DispatchTime.now()

        code()

        // 计算代码执行时间
        let nanoTime = DispatchTime.now().uptimeNanoseconds - startTime.uptimeNanoseconds
        let timeInterval = Double(nanoTime) / 1000000000

        if verbose && timeInterval > tolerance {
            os_log("\(self.label)\(title) cost \(timeInterval) 秒 🐢🐢🐢")
        }
    }
}

#Preview("App") {
    AppPreview()
}
