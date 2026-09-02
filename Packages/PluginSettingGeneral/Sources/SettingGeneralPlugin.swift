import CisumUI
import SwiftUI

/// 设置 - 通用 插件（复刻 Lumi `PluginSettingGeneral`）。
///
/// 在设置窗口注册「通用」导航入口（gearshape，order 1 排最前），详情展示
/// 应用信息等通用设置项。Cisum 无 DocsView / Sparkle 更新 / 官网 / 引导重放
/// 机制，Lumi 的新手引导、说明书、网站、更新分组按实际情况删减。
public actor SettingGeneralPlugin: SuperPlugin {
    public static let shared = SettingGeneralPlugin()
    public static let metadata = PluginMetadata(
        displayName: "通用设置",
        description: "在设置窗口中提供应用信息等通用设置项。",
        iconName: "gearshape",
        order: 1
    )

    @MainActor
    public func addSettingView() -> AnyView? {
        nil
    }

    @MainActor
    public func addSettingNavigationItem() -> PluginSettingNavigationItem? {
        PluginSettingNavigationItem(
            id: "general",
            title: "通用",
            description: Self.metadata.description,
            iconName: Self.metadata.iconName,
            order: Self.metadata.order,
            destination: AnyView(GeneralSettingsDetailView())
        )
    }
}
