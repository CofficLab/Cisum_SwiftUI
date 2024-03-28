import SwiftUI

@main
struct Boot: App {
    #if os(iOS)
        @UIApplicationDelegateAdaptor var appDelegate: AppDelegate
    #else
        @NSApplicationDelegateAdaptor var appDelegate: AppDelegate
    #endif

    var body: some Scene {
        #if os(macOS)
            Window("", id: "Cisum") {
                RootView{
                    ContentView()
                }
            }
            .windowStyle(.hiddenTitleBar)
            .defaultSize(width: 350, height: 500)
            .commands {
                DebugCommand()
            }
        #else
            WindowGroup {
                RootView {
                    ContentView(play: false)
                }
            }
        #endif
    }
}
