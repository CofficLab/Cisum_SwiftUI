import SwiftUI

/// 主题登记中心：排序、选择、同步外壳与组件主题。
@MainActor
public final class LumiUIThemeRegistry: ObservableObject {
    public static let shared = LumiUIThemeRegistry()

    @Published public private(set) var catalog: ThemeCatalog?

    @Published public private(set) var chromeTheme: any LumiAppChromeTheme = UnconfiguredChromeTheme()

    @Published public private(set) var uiTheme: any LumiUITheme = LumiDefaultTheme()

    public init() {}

    public var themes: [LumiUIThemeContribution] {
        catalog?.themes ?? []
    }

    public var selectedContribution: LumiUIThemeContribution? {
        catalog?.selected
    }

    public var selectedThemeId: String? {
        catalog?.selectedId
    }

    public func defaultThemeId() throws -> String {
        guard let id = catalog?.defaultThemeId else {
            throw ThemeError.noThemesRegistered
        }
        return id
    }

    /// 用新的贡献列表替换目录；空列表或重复 id 时抛出 ``ThemeError``。
    public func replaceAll(_ contributions: [LumiUIThemeContribution]) throws {
        let sorted = try sortedUnique(contributions)
        let previousId = catalog?.selectedId
        let selectedId: String
        if let previousId, sorted.contains(where: { $0.id == previousId }) {
            selectedId = previousId
        } else {
            guard let firstId = sorted.first?.id else {
                throw ThemeError.noThemesRegistered
            }
            selectedId = firstId
        }
        catalog = ThemeCatalog(themes: sorted, selectedId: selectedId)
        try applySelection()
    }

    /// 选中指定主题 id。
    public func select(themeId: String) throws {
        guard let catalog else {
            throw ThemeError.noThemesRegistered
        }
        guard catalog.themes.contains(where: { $0.id == themeId }) else {
            throw ThemeError.unknownThemeId(themeId)
        }
        self.catalog = ThemeCatalog(themes: catalog.themes, selectedId: themeId)
        try applySelection()
    }

    public func resolvedEditorThemeId(colorScheme: ColorScheme) -> String? {
        guard let contribution = selectedContribution else { return nil }
        return contribution.chromeTheme.resolvedEditorThemeId(
            defaultEditorThemeId: contribution.editorThemeId,
            colorScheme: colorScheme
        )
    }

    // MARK: - Private

    private func sortedUnique(_ contributions: [LumiUIThemeContribution]) throws -> [LumiUIThemeContribution] {
        guard !contributions.isEmpty else {
            throw ThemeError.noThemesRegistered
        }
        var seen = Set<String>()
        for contribution in contributions {
            if seen.contains(contribution.id) {
                throw ThemeError.duplicateThemeId(contribution.id)
            }
            seen.insert(contribution.id)
        }
        return contributions.sorted { $0.sortKey < $1.sortKey }
    }

    private func applySelection() throws {
        guard let contribution = catalog?.selected else {
            throw ThemeError.noThemesRegistered
        }
        chromeTheme = contribution.chromeTheme
        ActiveChromeTheme.current = contribution.chromeTheme
        let resolvedUI = contribution.uiTheme ?? ChromeToUIThemeAdapter(chrome: contribution.chromeTheme)
        uiTheme = resolvedUI
        LumiUIThemeStore.shared.setTheme(resolvedUI)
    }
}
