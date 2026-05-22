import SwiftUI

/// 应用外壳主题的动态颜色与渐变访问（绑定 ``ActiveChromeTheme``）。
public enum ChromeThemes {
    nonisolated(unsafe) public static var current: any LumiAppChromeTheme {
        get { ActiveChromeTheme.current }
        set { ActiveChromeTheme.current = newValue }
    }

    public enum Colors {
        public static var accent: AccentColors { AccentColors() }
        public static var atmosphere: AtmosphereColors { AtmosphereColors() }
        public static var glow: GlowColors { GlowColors() }
    }

    public struct AccentColors {
        public let primary: Color
        public let secondary: Color
        public let tertiary: Color

        public init(theme: (any LumiAppChromeTheme)? = nil) {
            let colors = (theme ?? current).accentColors()
            primary = colors.primary
            secondary = colors.secondary
            tertiary = colors.tertiary
        }
    }

    public struct AtmosphereColors {
        public let deep: Color
        public let medium: Color
        public let light: Color

        public init(theme: (any LumiAppChromeTheme)? = nil) {
            let colors = (theme ?? current).atmosphereColors()
            deep = colors.deep
            medium = colors.medium
            light = colors.light
        }
    }

    public struct GlowColors {
        public let subtle: Color
        public let medium: Color
        public let intense: Color

        public init(theme: (any LumiAppChromeTheme)? = nil) {
            let colors = (theme ?? current).glowColors()
            subtle = colors.subtle
            medium = colors.medium
            intense = colors.intense
        }
    }

    public enum Gradients {
        public static var auroraBackground: LinearGradient {
            current.backgroundGradient()
        }

        public static var mysticGlow: RadialGradient {
            current.glowGradient()
        }

        public static var mysticBorder: LinearGradient {
            current.borderGradient()
        }
    }

    public enum Effects {
        public static let glowRadius: CGFloat = 12
        public static let animationDuration: Double = 0.3
    }
}
