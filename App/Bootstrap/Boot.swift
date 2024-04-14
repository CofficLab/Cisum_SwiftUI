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
                RootView{
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
