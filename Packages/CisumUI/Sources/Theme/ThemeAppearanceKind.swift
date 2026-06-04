import Foundation

/// 主题外观类型：固定暗色、固定亮色，或跟随系统明暗。
public enum ThemeAppearanceKind: String, CaseIterable, Sendable, Identifiable {
    case dark
    case light
    case system

    public var id: String { rawValue }
}
