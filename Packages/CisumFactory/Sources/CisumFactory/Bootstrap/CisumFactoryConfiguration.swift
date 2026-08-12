import CisumKernel
import CisumUI
import Foundation

/// 宿主在编译期确定的内核组装配置。
///
/// 对齐 Lumi 的 `FactoryConfiguration`：携带插件清单与显式启用的插件 id 集合，
/// 在初始化时校验重复 id 与未知启用 id。插件清单由宿主（app target）提供，
/// Factory 本身不依赖任何具体插件。
public struct CisumFactoryConfiguration: @unchecked Sendable {
    /// 有序插件清单。
    public let plugins: [any SuperPlugin]

    /// 宿主显式启用的插件 id（必须是 `plugins` 中 id 的子集）。
    public let enabledPluginIDs: Set<String>

    @MainActor
    public init(plugins: [any SuperPlugin], enabledPluginIDs: Set<String> = []) throws {
        var seen = Set<String>()
        for plugin in plugins {
            guard seen.insert(plugin.id).inserted else {
                throw CisumFactoryError.duplicatePluginID(plugin.id)
            }
        }
        let unknown = enabledPluginIDs.subtracting(seen)
        if !unknown.isEmpty {
            throw CisumFactoryError.unknownEnabledPluginID(unknown.sorted().joined(separator: ", "))
        }
        self.plugins = plugins
        self.enabledPluginIDs = enabledPluginIDs
    }
}

public enum CisumFactoryError: LocalizedError {
    case duplicatePluginID(String)
    case unknownEnabledPluginID(String)

    public var errorDescription: String? {
        switch self {
        case let .duplicatePluginID(id): "Duplicate plugin ID: \(id)"
        case let .unknownEnabledPluginID(ids): "Unknown enabled plugin IDs: \(ids)"
        }
    }
}
