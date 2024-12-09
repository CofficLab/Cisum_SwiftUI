import OSLog
import SwiftUI

@main
struct BootApp: App {
    #if os(macOS)
        @NSApplicationDelegateAdaptor var appDelegate: AppDelegate
    #else
        @UIApplicationDelegateAdaptor var appDelegate: AppDelegate
    #endif

    static var label = "🍎 Boot::"
    var label: String { "\(Logger.isMain)\(Self.label)" }

    var body: some Scene {
        #if os(macOS)
            Window("", id: "Cisum") {
                RootView {
                    ContentView()
                }
                .frame(minWidth: Config.minWidth, minHeight: Config.minHeight)
            }
            .windowToolbarStyle(.unifiedCompact(showsTitle: false))
            .defaultSize(width: Config.minWidth, height: Config.defaultHeight)
            .modelContainer(Config.getContainer)
            .commands {
                DebugCommand()
            }
        #else
            WindowGroup {
                BootView {
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
