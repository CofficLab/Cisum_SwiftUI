import OSLog
import SwiftUI
import MagicKit

import MagicPlayMan

typealias PlayMan = MagicPlayMan
typealias PlayAsset = MagicAsset
typealias PlayMode = MagicPlayMode

@main
struct BootApp: App, @preconcurrency SuperLog {
    #if os(macOS)
        @NSApplicationDelegateAdaptor var appDelegate: AppDelegate
    #else
        @UIApplicationDelegateAdaptor var appDelegate: AppDelegate
    #endif

    static let emoji = "🍎"

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
            .commands {
                SidebarCommands()
                MagicApp.debugCommand()
            }
        #else
            WindowGroup {
                RootView {
                    ContentView()
                }
            }
        #endif
    }
}

#Preview {
    AppPreview()
}

#Preview {
    LayoutView()
}
