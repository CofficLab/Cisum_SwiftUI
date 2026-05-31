import CisumUI
import MagicAlert
import MagicKit
import MagicPlayMan
import OSLog
import PluginStore
import SwiftUI

typealias PlayMan = MagicPlayMan
typealias PlayAsset = MagicAsset
typealias PlayMode = MagicPlayMode
typealias MagicApp = MagicKit.MagicApp
typealias SuperLog = MagicKit.SuperLog
typealias SuperEvent = MagicKit.SuperEvent
typealias SuperThread = MagicKit.SuperThread
typealias MagicSettingSection = CisumUI.MagicSettingSection
typealias MagicSettingRow = CisumUI.MagicSettingRow

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
            Window("Cisum", id: "Cisum") {
                ContentView()
                    .inRootView(providers: ProviderManager.shared)
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
                    .inRootView(providers: ProviderManager.shared)
            }
        #endif
    }
}

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}
