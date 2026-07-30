import CisumUI
import Foundation
import SwiftUI

/// 主题服务能力协议。
///
/// 管理应用主题的贡献收集、选择与持久化，以及主题状态同步。
///
/// ## 使用示例
///
/// ```swift
/// kernel.theme?.selectTheme("cisum.aurora")
/// let isDark = kernel.theme?.colorScheme == .dark
/// ```
@MainActor
public protocol ThemeProviding: AnyObject, ObservableObject {
    /// 当前选中主题的标识符。
    var selectedThemeID: String { get }

    /// 当前色彩方案。
    var colorScheme: ThemeColorScheme { get }

    /// 所有可用的主题贡献。
    var allThemeContributions: [LumiUIThemeContribution] { get }

    /// 选中一个主题。
    ///
    /// - Parameter themeID: 主题标识符。
    func selectTheme(_ themeID: String)

    /// 将内核主题服务中的贡献同步到 CisumUI 的主题注册中心。
    func syncToCisumUI()
}

/// 主题色彩方案。
public enum ThemeColorScheme: String, Sendable, CaseIterable {
    /// 跟随系统。
    case system
    /// 浅色模式。
    case light
    /// 深色模式。
    case dark
}
