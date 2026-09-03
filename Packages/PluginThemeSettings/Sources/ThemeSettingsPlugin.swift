import CisumUIComponents
import KernelCore
import SwiftUI

/// 主题设置插件（对齐 Lumi `ThemePackPlugin` 的设置入口范式）。
///
/// Lumi 的 `ThemePackPlugin` 在设置窗口注册独立的「外观」（paintpalette，
/// order 2）入口，详情页列出全部主题供切换——Cisum 复刻该入口：
/// - macOS：贡献 `appearance` 导航项，右侧为主题管理详情页；
/// - iOS：设置窗口为简化版（导航项不可交互），主题设置保留在「插件设置」
///   聚合页中，避免入口丢失。
public actor ThemeSettingsPlugin: SuperPlugin {
    public static let shared = ThemeSettingsPlugin()
    public static let metadata = PluginMetadata(
        displayName: ThemeSettingsPluginInfo.title,
        description: ThemeSettingsPluginInfo.description,
        iconName: ThemeSettingsPluginInfo.iconName,
        order: ThemeSettingsPluginInfo.order
    )

    @MainActor
    public func addSettingNavigationItem() -> PluginSettingNavigationItem? {
        PluginSettingNavigationItem(
            id: "appearance",
            title: String(localized: "Appearance", bundle: .module),
            description: Self.metadata.description,
            iconName: "paintpalette",
            order: 2,
            destination: AnyView(ThemeSettingsDetailView())
        )
    }
}
