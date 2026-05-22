import SwiftUI

/// 当前应用外壳主题的全局访问（由 ``LumiUIThemeRegistry`` 同步）。
public enum ActiveChromeTheme {
    nonisolated(unsafe) public static var current: any LumiAppChromeTheme = UnconfiguredChromeTheme()
}

// MARK: - Placeholder

struct UnconfiguredChromeTheme: LumiAppChromeTheme {
    let identifier = "__unconfigured__"
    let displayName = ""
    let compactName = ""
    let description = ""
    let iconName = "circle.dashed"
    let iconColor = Color.clear

    func accentColors() -> (primary: Color, secondary: Color, tertiary: Color) {
        (.clear, .clear, .clear)
    }

    func atmosphereColors() -> (deep: Color, medium: Color, light: Color) {
        (.clear, .clear, .clear)
    }

    func glowColors() -> (subtle: Color, medium: Color, intense: Color) {
        (.clear, .clear, .clear)
    }
}
