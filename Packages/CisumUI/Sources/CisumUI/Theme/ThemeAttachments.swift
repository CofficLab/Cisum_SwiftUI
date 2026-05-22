import Foundation

/// 宿主应用可选附件（编辑器 / 文件树等），LumiUI 不解释具体类型。
public struct ThemeAttachments {
    public var editorThemeContributor: AnyObject?
    public var fileIconThemeContributor: AnyObject?

    public init(
        editorThemeContributor: AnyObject? = nil,
        fileIconThemeContributor: AnyObject? = nil
    ) {
        self.editorThemeContributor = editorThemeContributor
        self.fileIconThemeContributor = fileIconThemeContributor
    }
}
