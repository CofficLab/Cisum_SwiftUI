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
        @Environment(\.openWindow) private var openWindow
    #else
        @UIApplicationDelegateAdaptor var appDelegate: AppDelegate
    #endif

    nonisolated static let emoji = "🍎"

    init() {
        #if os(macOS)
            UserDefaults.standard.set(true, forKey: "ApplePersistenceIgnoreState")
        #endif
        StoreService.bootstrap()
    }

    var body: some Scene {
        #if os(macOS)
            WindowGroup("Cisum", id: "Cisum") {
                ContentView()
                    .inRootView(providers: ProviderManager.shared)
                    .frame(minWidth: Config.minWidth, minHeight: Config.minHeight)
            }
            .windowToolbarStyle(.unifiedCompact(showsTitle: false))
            .defaultSize(width: Config.minWidth, height: Config.defaultHeight)
            .commands {
                CommandGroup(replacing: .newItem) {
                    Button(String(localized: "Show Cisum", table: "Core")) {
                        if !AppWindowController.showExistingMainWindow() {
                            openWindow(id: AppWindowController.mainWindowID)
                        }
                    }
                    .keyboardShortcut("n")
                }
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

#if os(macOS)
    @MainActor
    enum AppWindowController {
        static let mainWindowID = "Cisum"

        @discardableResult
        static func showExistingMainWindow(in app: NSApplication = .shared) -> Bool {
            guard let window = app.windows.first(where: isMainAppWindow) else { return false }

            if window.isMiniaturized {
                window.deminiaturize(nil)
            }
            app.activate(ignoringOtherApps: true)
            window.makeKeyAndOrderFront(nil)
            return true
        }

        private static func isMainAppWindow(_ window: NSWindow) -> Bool {
            (window.isVisible || window.isMiniaturized)
                && window.canBecomeMain
                && window.level == .normal
        }
    }
#endif

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}
