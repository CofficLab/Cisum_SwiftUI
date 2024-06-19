import SwiftUI
import OSLog

@main
struct Boot: App {
    #if os(macOS)
        @NSApplicationDelegateAdaptor var appDelegate: AppDelegate
    #else
        @UIApplicationDelegateAdaptor var appDelegate: AppDelegate
    #endif
    
    static var label = "🍎 Boot::"
    var label:String { "\(Logger.isMain)\(Self.label)" }

    var body: some Scene {
        #if os(macOS)
            Window("", id: "Cisum") {
                RootView {
                    ContentView()
                }
                .frame(minWidth: Config.minWidth, minHeight: Config.minHeight)
            }
            .windowStyle(.hiddenTitleBar)
            .defaultSize(width: Config.minWidth, height: Config.defaultHeight)
            .modelContainer(Config.getContainer)
            .commands {
                DebugCommand()
            }
        #else
            WindowGroup {
                RootView {
                    ContentView()
                }
            }
            .modelContainer(Config.getContainer)
        #endif
    }
}

#Preview {
    AppPreview()
}

#Preview {
    LayoutView()
}
