import SwiftUI

public extension LumiUIThemeContribution {
    /// 插件侧便捷构造：`sortKey` 由宿主在聚合时按插件 `order` 重写。
    init(
        appTheme: any LumiAppChromeTheme,
        editorThemeId: String,
        editorThemeContributor: AnyObject? = nil,
        fileIconThemeContributor: AnyObject? = nil
    ) {
        self.init(
            sortKey: ThemeSortKey(pluginOrder: Int.max, themeId: appTheme.identifier),
            chromeTheme: appTheme,
            editorThemeId: editorThemeId,
            editorThemeContributor: editorThemeContributor,
            fileIconThemeContributor: fileIconThemeContributor
        )
    }
}
