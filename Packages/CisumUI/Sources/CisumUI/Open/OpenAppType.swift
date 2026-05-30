import SwiftUI

/// 应用程序打开类型
public enum OpenAppType: String {
    /// 自动选择（根据URL类型智能选择）
    case auto
    /// 在Xcode中打开
    case xcode
    /// 在VS Code中打开
    case vscode
    /// 在Cursor中打开
    case cursor
    /// 在Trae中打开
    case trae
    /// 在Antigravity中打开
    case antigravity
    /// 在Chrome中打开
    case chrome
    /// 在Safari中打开
    case safari
    /// 在Arc中打开
    case arc
    /// 在Firefox中打开
    case firefox
    /// 在Edge中打开
    case edge
    /// 在终端中打开
    case terminal
    /// 在预览中打开
    case preview
    /// 在文本编辑器中打开
    case textEdit
    /// 在访达中显示
    case finder
    /// 在默认浏览器中打开
    case browser
    /// 在 GitHub Desktop 中打开
    case githubDesktop
    /// 在Kiro中打开
    case kiro

    // MARK: - App Registry Mapping

    /// 映射到 AppRegistry（如果适用）
    var appRegistry: AppRegistry? {
        switch self {
        case .auto, .browser:
            return nil
        case .xcode:
            return .xcode
        case .vscode:
            return .vscode
        case .cursor:
            return .cursor
        case .trae:
            return .trae
        case .antigravity:
            return .antigravity
        case .chrome:
            return .chrome
        case .safari:
            return .safari
        case .arc:
            return .arc
        case .firefox:
            return .firefox
        case .edge:
            return .edge
        case .terminal:
            return .terminal
        case .preview:
            return .preview
        case .textEdit:
            return .textEdit
        case .finder:
            return .finder
        case .githubDesktop:
            return .githubDesktop
        case .kiro:
            return .kiro
        }
    }

    // MARK: - Properties

    /// 获取应用程序的Bundle ID
    var bundleId: String? {
        // 特殊情况：auto 和 browser 没有固定的 bundleId
        if self == .auto || self == .browser {
            return nil
        }
        // 使用 AppRegistry 获取 bundleId
        return appRegistry?.bundleId
    }

    /// 获取应用程序的图标
    var icon: String {
        switch self {
        case .auto:
            return .iconGear // 使用齿轮图标表示自动选择
        case .browser:
            return .iconSafari
        case .finder:
            return .iconShowInFinder // 使用"在访达中显示"图标
        default:
            // 使用 AppRegistry 的系统图标
            return appRegistry?.systemIcon ?? "app"
        }
    }

    /// 获取应用程序的显示名称
    var displayName: String {
        switch self {
        case .auto:
            return "智能打开"
        case .browser:
            return "在浏览器中打开"
        case .finder:
            return "在访达中显示"
        default:
            // 使用 AppRegistry 的显示名称，加上"在...中打开"前缀
            guard let appName = appRegistry?.displayName else { return "" }
            return "在\(appName)中打开"
        }
    }

    /// 根据URL获取图标（用于auto类型）
    func icon(for url: URL) -> String {
        if self == .auto {
            return url.isNetworkURL ? .iconSafari : .iconShowInFinder
        }
        return icon
    }

    /// 根据URL获取显示名称（用于auto类型）
    func displayName(for url: URL) -> String {
        if self == .auto {
            return url.isNetworkURL ? "在浏览器中打开" : "在访达中显示"
        }
        return displayName
    }

    #if os(macOS)
        /// 检查应用是否已安装
        var isInstalled: Bool {
            // 特殊类型：auto 和 browser 认为总是可用
            if self == .auto || self == .browser {
                return true
            }
            // 使用 AppRegistry 的安装检查
            return appRegistry?.isInstalled ?? false
        }

        /// 获取应用的真实图标（如果已安装）
        /// - Parameter useRealIcon: 是否使用真实应用图标，默认为false使用系统图标
        /// - Returns: 图标名称或NSImage
        func realIcon(useRealIcon: Bool = false) -> Any {
            // 特殊情况：auto 和 browser 没有真实图标
            if self == .auto || self == .browser {
                return icon
            }
            // 使用 AppRegistry 的真实图标
            return appRegistry?.icon(useRealIcon: useRealIcon) ?? icon
        }

        /// 根据URL获取真实图标（用于auto类型）
        /// - Parameters:
        ///   - url: URL对象
        ///   - useRealIcon: 是否使用真实应用图标
        /// - Returns: 图标名称或NSImage
        func realIcon(for url: URL, useRealIcon: Bool = false) -> Any {
            if self == .auto {
                return url.isNetworkURL ? String.iconSafari : String.iconShowInFinder
            }
            return realIcon(useRealIcon: useRealIcon)
        }

    #else
        /// 获取 Image 类型的图标（iOS版本）
        /// - Parameter useRealIcon: 是否使用真实应用图标（iOS上忽略此参数）
        /// - Returns: SwiftUI Image
        func magicButtonIcon(useRealIcon: Bool = false) -> Image {
            return Image(systemName: icon)
        }

        /// 根据URL获取 Image 类型的图标（用于auto类型，iOS版本）
        /// - Parameters:
        ///   - url: URL对象
        ///   - useRealIcon: 是否使用真实应用图标（iOS上忽略此参数）
        /// - Returns: SwiftUI Image
        func magicButtonIcon(for url: URL, useRealIcon: Bool = false) -> Image {
            if self == .auto {
                let iconName = url.isNetworkURL ? String.iconSafari : String.iconShowInFinder
                return Image(systemName: iconName)
            }
            return Image(systemName: icon)
        }
    #endif
}

#if macOS
    #Preview("Open Buttons") {
        OpenPreivewView()
    }
#endif
