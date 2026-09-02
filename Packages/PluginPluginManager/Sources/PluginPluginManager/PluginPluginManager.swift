import CisumKernel
import CisumUI
import ProviderPluginManaging
import SwiftUI

/// 插件管理插件（复刻 Lumi `PluginPluginManager`）。
///
/// 在设置窗口注册「插件管理」导航入口（puzzlepiece.extension，order 90），
/// 详情展示所有可配置插件的列表 + 启停开关。onBoot 保存内核引用，
/// 供 `addSettingNavigationItem()` 构造 `PluginManaging` 数据源。
public actor PluginPluginManager: SuperPlugin, CisumKernelPlugin {
    public static let shared = PluginPluginManager()
    public static let metadata = PluginMetadata(
        displayName: "插件管理",
        description: "管理所有已注册插件。",
        iconName: "puzzlepiece.extension",
        order: 90,
        policy: .alwaysOn
    )

    /// 设置导航项稳定 ID。
    static let settingsEntryID = "plugin-manager"

    /// onBoot 时保存的内核引用，用于构建插件管理数据源。
    ///
    /// 仅在主线程访问（onBoot / addSettingNavigationItem 均 @MainActor）。
    nonisolated(unsafe) private var kernel: CisumKernel?

    public init() {}

    public func onBoot(kernel: CisumKernel) async throws {
        self.kernel = kernel
    }

    @MainActor
    public func addSettingView() -> AnyView? {
        nil
    }

    @MainActor
    public func addSettingNavigationItem() -> PluginSettingNavigationItem? {
        guard let kernel else { return nil }
        let manager = DefaultPluginManaging(manager: kernel.pluginManager, kernel: kernel)
        return PluginSettingNavigationItem(
            id: Self.settingsEntryID,
            title: "插件管理",
            description: Self.metadata.description,
            iconName: Self.metadata.iconName,
            order: Self.metadata.order,
            destination: AnyView(PluginManagementView(manager: manager))
        )
    }
}
