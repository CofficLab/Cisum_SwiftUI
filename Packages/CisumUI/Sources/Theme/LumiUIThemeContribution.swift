import SwiftUI

/// 登记到 ``LumiUIThemeRegistry`` 的完整主题贡献。
public struct LumiUIThemeContribution: Identifiable {
    public let sortKey: ThemeSortKey
    public let id: String
    public let displayName: String
    public let description: String
    public let iconName: String
    public let iconColor: Color
    public let chromeTheme: any LumiAppChromeTheme
    public let uiTheme: (any LumiUITheme)?

    public var appearanceKind: ThemeAppearanceKind {
        chromeTheme.appearanceKind
    }

    public init(
        sortKey: ThemeSortKey,
        chromeTheme: any LumiAppChromeTheme,
        uiTheme: (any LumiUITheme)? = nil
    ) {
        self.sortKey = sortKey
        self.id = chromeTheme.identifier
        self.displayName = chromeTheme.displayName
        self.description = chromeTheme.description
        self.iconName = chromeTheme.iconName
        self.iconColor = chromeTheme.iconColor
        self.chromeTheme = chromeTheme
        self.uiTheme = uiTheme
    }
}
