import FactoryCisum
import PluginStore
import SwiftUI

/// 宿主在编译期确定的内核组装配置。
///
/// 插件清单由 `FactoryCisum` 的 `DefaultPluginFactory` 直接装配（对齐 Lumi，
/// Factory 是唯一知道"应用由哪些插件组成"的地方），宿主不再注入插件列表。
@MainActor
private enum CisumAppAssembly {
    static let configuration = FactoryCisumConfiguration()
}

@main
struct NewApp: App {
    #if os(macOS)
    @NSApplicationDelegateAdaptor private var appDelegate: AppDelegate
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
            FactoryCisum.makeMainWindow(configuration: CisumAppAssembly.configuration)
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified(showsTitle: false))
        .defaultSize(
            width: AppBootstrap.defaultWindowSize.width,
            height: AppBootstrap.defaultWindowSize.height
        )
        .commands {
            // 命令装配集中在 Factory 包内（CisumAppCommands，含「设置…」⌘,）。
            FactoryCisum.makeCommands()
        }

        Window("设置", id: AppBootstrap.settingsWindowID) {
            FactoryCisum.makeSettingsWindow(configuration: CisumAppAssembly.configuration)
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified(showsTitle: false))
        .defaultSize(
            width: AppBootstrap.defaultSettingsWindowSize.width,
            height: AppBootstrap.defaultSettingsWindowSize.height
        )
        #else
        WindowGroup(AppBootstrap.appName, id: AppBootstrap.mainWindowID) {
            FactoryCisum.makeMainWindow(configuration: CisumAppAssembly.configuration)
        }
        #endif
    }
}
