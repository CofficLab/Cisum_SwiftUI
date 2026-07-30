import CisumKernel
import CisumUI
import Foundation

/// 内置插件清单。
///
/// 持有所有内置插件的实例，是应用中唯一知道"要装哪些插件"的地方。
/// 插件按 `order` 升序注册到 `BuiltinPluginManager`。
///
/// 当前为初始状态，尚未注册任何插件。
@MainActor
public enum PluginService {
    /// 所有内置插件列表。
    ///
    /// 顺序即注册顺序，`BuiltinPluginManager` 会在初始化时按各插件的 `order` 重新排序。
    public static let plugins: [any SuperPlugin] = []
}
