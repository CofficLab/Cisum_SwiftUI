import PluginRegistry
import Foundation

/// Core 与 CisumUI 主题注册表之间的桥梁。
@MainActor
final class ThemeService {
    static let shared = ThemeService()

    private init() {}

    func syncFromPlugins(
        pluginVM: PluginVM,
        registry: LumiUIThemeRegistry = .shared
    ) throws {
        let contributions = pluginVM.getThemeContributions()
        try registry.replaceAll(contributions)
    }
}
