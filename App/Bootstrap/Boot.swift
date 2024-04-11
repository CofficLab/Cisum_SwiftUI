import SwiftUI

@main
struct Boot: App {
    #if os(macOS)
        @NSApplicationDelegateAdaptor var appDelegate: AppDelegate
    #else
        @UIApplicationDelegateAdaptor var appDelegate: AppDelegate
    #endif

    var body: some Scene {
        #if os(macOS)
            Window("", id: "Cisum") {
                RootView {
                    ContentView()
                }
            }
            .windowStyle(.hiddenTitleBar)
            .defaultSize(width: 350, height: 500)
            .modelContainer(AppConfig.getContainer())
            .commands {
                DebugCommand()
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
    RootView {
        ContentView()
    }
    .modelContainer(AppConfig.getContainer())
}
