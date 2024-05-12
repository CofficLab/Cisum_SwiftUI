import SwiftUI
import OSLog

@main
struct Boot: App {
    #if os(macOS)
        @NSApplicationDelegateAdaptor var appDelegate: AppDelegate
    #else
        @UIApplicationDelegateAdaptor var appDelegate: AppDelegate
    #endif

    @Environment(\.scenePhase) private var scenePhase
    
    static var label = "🍎 Boot::"
    var db = DB(AppConfig.getContainer())
    var label:String { "\(Logger.isMain)\(Self.label)" }

    var body: some Scene {
        #if os(macOS)
            Window("", id: "Cisum") {
                RootView {
                    ContentView()
                }
                .frame(minWidth: AppConfig.minWidth, minHeight: AppConfig.minHeight)
            }
            .windowStyle(.hiddenTitleBar)
            .defaultSize(width: AppConfig.minWidth, height: AppConfig.defaultHeight)
            .modelContainer(AppConfig.getContainer())
            .commands {
                DebugCommand()
            }
            .onChange(of: scenePhase) {
                switch scenePhase {
                case .active:
                    os_log("\(self.label)App is active")
                    Task {
                        await db.stopFindDuplicatedsJob()
                    }
                case .inactive:
                    os_log("\(self.label)App is inactive")
                    
                    Task.detached(priority: .background, operation: {
                        await db.getCovers()
                    })
                    
                    Task.detached(priority: .background, operation: {
                        await db.findDuplicatesJob(verbose:true)
                    })
                    
                    Task.detached(priority: .background, operation: {
                        await db.prepareJob()
                    })
                case .background:
                    os_log("\(self.label)App is in background (minimized)")
                @unknown default:
                    os_log("\(self.label)Unknown scene phase")
                }
            }
        #else
            WindowGroup {
                RootView {
                    ContentView()
                }
            }
            .modelContainer(AppConfig.getContainer())
        #endif
    }
}

#Preview {
    LayoutView()
}
