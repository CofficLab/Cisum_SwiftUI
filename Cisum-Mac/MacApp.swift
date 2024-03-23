import SwiftUI
import OSLog

@main
struct MacApp: App {
    @StateObject var audioManager = AudioManager.shared
    @StateObject var databaseManager = DatabaseManager.shared
    
    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(audioManager)
                .environmentObject(databaseManager)
                .frame(minWidth: 400, minHeight: 300)
        }.onChange(of: scenePhase) { newScenePhase in
            switch newScenePhase {
            case .active:
                AppConfig.logger.app.debugSomething("启动了")
            case .inactive:
                AppConfig.logger.app.debugSomething("休眠了")
            case .background:
                AppConfig.logger.app.debugSomething("在后台展示")
            @unknown default:
                AppConfig.logger.app.debugSomething("default")
            }
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 500, height: 500)
    }
}
