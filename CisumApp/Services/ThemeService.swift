import CisumUI
import Foundation

/// Core 与 CisumUI 主题注册表之间的桥梁。
@MainActor
final class ThemeService {
    static let shared = ThemeService()

    private init() {}

    func syncFromPlugins(
        pluginProvider: PluginProvider,
        registry: LumiUIThemeRegistry = .shared
    ) throws {
        let contributions = pluginProvider.getThemeContributions()
        try registry.replaceAll(contributions)
    }
}
