import CisumFactory
import PluginRegistry
import SwiftUI

/// 宿主（app target）在编译期确定的插件清单与内核组装配置。
///
/// 插件清单来自 `PluginRegistry`；Factory 本身不依赖任何具体插件，
/// 由这里显式注入，保持依赖方向单向（App → Factory + Registry）。
@MainActor
private enum CisumAppAssembly {
    static let configuration = try! CisumFactoryConfiguration(plugins: PluginRegistry.plugins)
}

@main
struct NewApp: App {
    #if os(macOS)
    @NSApplicationDelegateAdaptor private var appDelegate: AppDelegate
    @Environment(\.openWindow) private var openWindow
    #endif

    init() {
        #if os(macOS)
        UserDefaults.standard.set(true, forKey: "ApplePersistenceIgnoreState")
        #endif
        StoreService.bootstrap()
    }

    var body: some Scene {
        #if os(macOS)
        WindowGroup(AppBootstrap.appName, id: AppBootstrap.mainWindowID) {
            CisumFactory.makeMainWindow(configuration: CisumAppAssembly.configuration)
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified(showsTitle: false))
        .defaultSize(
            width: AppBootstrap.defaultWindowSize.width,
            height: AppBootstrap.defaultWindowSize.height
        )
        .commands {
            CisumFactory.makeCommands()
            // 菜单栏「设置…」入口（⌘,）——对齐 Lumi 的设置窗口入口。
            CommandGroup(replacing: .appSettings) {
                Button("设置…") {
                    openWindow(id: AppBootstrap.settingsWindowID)
                }
                .keyboardShortcut(",", modifiers: .command)
            }
        }

        Window("设置", id: AppBootstrap.settingsWindowID) {
            CisumFactory.makeSettingsWindow(configuration: CisumAppAssembly.configuration)
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified(showsTitle: false))
        .defaultSize(
            width: AppBootstrap.defaultSettingsWindowSize.width,
            height: AppBootstrap.defaultSettingsWindowSize.height
        )
        #else
        WindowGroup(AppBootstrap.appName, id: AppBootstrap.mainWindowID) {
            CisumFactory.makeMainWindow(configuration: CisumAppAssembly.configuration)
        }
        #endif
    }
}
