import CisumUI

/// 产出各种插件的工厂协议（对齐 Lumi `FactoryLumi/PluginFactory.swift`）。
///
/// 集中管理插件的构造；`FactoryCisum.createKernel` 通过它产出插件并交给
/// `BuiltinPluginManager` 启动。宿主可实现该协议覆盖插件列表。
@MainActor
public protocol PluginFactory {
    /// 产出要启动的全部插件。
    ///
    /// 各插件在 `onBoot` 中解析内核已有 Provider 并注册自己的贡献
    /// （如 SettingGeneralPlugin 注册「通用」入口、PluginPluginManager 注册
    /// 「插件管理」入口）。
    func makePlugins() -> [any SuperPlugin]
}

/// 默认插件工厂：产出宿主传入的插件清单。
///
/// Cisum 的插件清单由宿主（app target）通过 `PluginRegistry` 提供，
/// Factory 本身不依赖任何具体插件。
public struct DefaultPluginFactory: PluginFactory {
    private let plugins: [any SuperPlugin]

    public init(plugins: [any SuperPlugin]) {
        self.plugins = plugins
    }

    public func makePlugins() -> [any SuperPlugin] {
        plugins
    }
}

/// 按允许 ID 列表过滤的插件工厂（对齐 Lumi `SelectedPluginFactory`）。
///
/// 用于「只装配启用集合中的插件」的场景；运行期启停仍由内核的
/// override 机制 + 贡献重建驱动。
public struct SelectedPluginFactory: PluginFactory {
    private let base: any PluginFactory
    public let allowedPluginIDs: Set<String>

    public init(allowedPluginIDs: Set<String>) {
        self.allowedPluginIDs = allowedPluginIDs
        self.base = DefaultPluginFactory(plugins: [])
    }

    public init(allowedPluginIDs: Set<String>, base: any PluginFactory) {
        self.allowedPluginIDs = allowedPluginIDs
        self.base = base
    }

    public func makePlugins() -> [any SuperPlugin] {
        base.makePlugins().filter { allowedPluginIDs.contains($0.id) }
    }
}
