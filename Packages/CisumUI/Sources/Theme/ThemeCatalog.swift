import Foundation

/// 主题目录不可变快照（便于测试与 UI 绑定）。
struct ThemeCatalog: Equatable {
    let themes: [LumiUIThemeContribution]
    let selectedId: String

    init(themes: [LumiUIThemeContribution], selectedId: String) {
        self.themes = themes
        self.selectedId = selectedId
    }

    var selected: LumiUIThemeContribution? {
        themes.first { $0.id == selectedId }
    }

    static func == (lhs: ThemeCatalog, rhs: ThemeCatalog) -> Bool {
        lhs.selectedId == rhs.selectedId && lhs.themes.map(\.id) == rhs.themes.map(\.id)
    }
}
