import CisumFactory
import SwiftUI

@main
struct NewApp: App {
    @NSApplicationDelegateAdaptor private var appDelegate: AppDelegate

    var body: some Scene {
        WindowGroup(AppBootstrap.appName, id: AppBootstrap.mainWindowID) {
            CisumFactory.makeMainWindow()
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified(showsTitle: false))
        .defaultSize(
            width: AppBootstrap.defaultWindowSize.width,
            height: AppBootstrap.defaultWindowSize.height
        )
        .commands {
            CisumFactory.makeCommands()
        }

        #if os(macOS)
        Window(String(localized: "设置"), id: AppBootstrap.settingsWindowID) {
            CisumFactory.makeSettingsWindow()
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified(showsTitle: false))
        .defaultSize(
            width: AppBootstrap.defaultSettingsWindowSize.width,
            height: AppBootstrap.defaultSettingsWindowSize.height
        )
        #endif
    }
}
