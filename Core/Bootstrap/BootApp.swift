import MagicAlert
import MagicKit
import MagicPlayMan
import MagicUI
import OSLog
import SwiftUI

typealias PlayMan = MagicPlayMan
typealias PlayAsset = MagicAsset
typealias PlayMode = MagicPlayMode
typealias Logger = MagicLogger
typealias MagicApp = MagicKit.MagicApp
typealias SuperLog = MagicKit.SuperLog
typealias MagicLoading = MagicUI.MagicLoading
typealias MagicMessageProvider = MagicAlert.MagicMessageProvider
typealias MagicSettingSection = MagicUI.MagicSettingSection
typealias MagicSettingRow = MagicUI.MagicSettingRow

@main
struct BootApp: App, SuperLog {
    #if os(macOS)
        @NSApplicationDelegateAdaptor var appDelegate: AppDelegate
    #else
        @UIApplicationDelegateAdaptor var appDelegate: AppDelegate
    #endif

    nonisolated static let emoji = "🍎"

    init() {
        StoreService.bootstrap()
    }

    var body: some Scene {
        #if os(macOS)
            Window("", id: "Cisum") {
                ContentView()
                    .inRootView()
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
                ContentView()
                    .inRootView()
            }
        #endif
    }
}

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .inPreviewMode()
}
