import Foundation

/// 主题列表排序键。由宿主应用根据插件 `order` 与主题 `id` 填入；LumiUI 仅做比较。
public struct ThemeSortKey: Comparable, Sendable, Hashable {
    public let pluginOrder: Int
    public let themeId: String

    public init(pluginOrder: Int, themeId: String) {
        self.pluginOrder = pluginOrder
        self.themeId = themeId
    }

    public static func < (lhs: ThemeSortKey, rhs: ThemeSortKey) -> Bool {
        if lhs.pluginOrder != rhs.pluginOrder {
            return lhs.pluginOrder < rhs.pluginOrder
        }
        return lhs.themeId < rhs.themeId
    }
}
