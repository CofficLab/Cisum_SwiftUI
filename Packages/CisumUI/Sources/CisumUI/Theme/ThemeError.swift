import Foundation

public enum ThemeError: Error, Equatable, Sendable {
    case noThemesRegistered
    case duplicateThemeId(String)
    case unknownThemeId(String)
}
