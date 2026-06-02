import SwiftUI

public protocol LumiUITheme {
    var id: String { get }
    var name: String { get }

    var primary: Color { get }
    var primarySecondary: Color { get }

    var textPrimary: Color { get }
    var textSecondary: Color { get }
    var textTertiary: Color { get }
    var textDisabled: Color { get }

    var background: Color { get }
    var surface: Color { get }
    var elevatedSurface: Color { get }
    var overlay: Color { get }
    var divider: Color { get }

    var success: Color { get }
    var successGlow: Color { get }
    var warning: Color { get }
    var warningGlow: Color { get }
    var error: Color { get }
    var errorGlow: Color { get }
    var info: Color { get }
    var infoGlow: Color { get }

    var primaryGradient: LinearGradient { get }
    var oceanGradient: LinearGradient { get }
    var auroraGradient: LinearGradient { get }
    var energyGradient: LinearGradient { get }
    var glowBorderGradient: LinearGradient { get }

    var glowAccent: Color { get }
}

public extension LumiUITheme {
    var successGlow: Color { success.opacity(0.65) }
    var warningGlow: Color { warning.opacity(0.65) }
    var errorGlow: Color { error.opacity(0.65) }
    var infoGlow: Color { info.opacity(0.65) }

    var primaryGradient: LinearGradient {
        LinearGradient(
            colors: [primary, primarySecondary],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var oceanGradient: LinearGradient {
        LinearGradient(
            colors: [background, elevatedSurface],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var auroraGradient: LinearGradient {
        LinearGradient(
            colors: [primary, primarySecondary, info],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var energyGradient: LinearGradient {
        LinearGradient(
            colors: [info, primary],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    var glowBorderGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.clear,
                divider.opacity(0.55),
                Color.clear,
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var glowAccent: Color { primary }
}

public struct LumiDefaultTheme: LumiUITheme {
    public let id = "lumi-default"
    public let name = "Lumi Default"

    public let primary = Color.adaptive(light: "7C6FFF", dark: "7C6FFF")
    public let primarySecondary = Color.adaptive(light: "A99CFF", dark: "A99CFF")

    public let textPrimary = Color.adaptive(light: "1C1C1E", dark: "FFFFFF")
    public let textSecondary = Color.adaptive(light: "6B6B7B", dark: "EBEBF5")
    public let textTertiary = Color.adaptive(light: "98989E", dark: "98989E")
    public let textDisabled = Color.adaptive(light: "BDBDBD", dark: "48484F")

    public let background = Color.adaptive(light: "F5F5F7", dark: "050508")
    public let surface = Color.adaptive(light: "FFFFFF", dark: "0D0D12")
    public let elevatedSurface = Color.adaptive(light: "FFFFFF", dark: "14141A")
    public let overlay = Color.adaptive(light: "E5E5EA", dark: "1A1A22")
    public let divider = Color.adaptive(light: "E5E5EA", dark: "FFFFFF").opacity(0.15)

    public let success = Color.adaptive(light: "30D158", dark: "30D158")
    public let successGlow = Color.adaptive(light: "7CFFB5", dark: "7CFFB5")
    public let warning = Color.adaptive(light: "FF9F0A", dark: "FF9F0A")
    public let warningGlow = Color.adaptive(light: "FFD57F", dark: "FFD57F")
    public let error = Color.adaptive(light: "FF453A", dark: "FF453A")
    public let errorGlow = Color.adaptive(light: "FF7A73", dark: "FF7A73")
    public let info = Color.adaptive(light: "0A84FF", dark: "0A84FF")
    public let infoGlow = Color.adaptive(light: "7AB8FF", dark: "7AB8FF")

    public let glowAccent = Color(hex: "6B5CE7")

    public init() {}
}

@MainActor
public final class LumiUIThemeStore: ObservableObject {
    public static let shared = LumiUIThemeStore()

    @Published public private(set) var theme: any LumiUITheme

    private init(theme: any LumiUITheme = LumiDefaultTheme()) {
        self.theme = theme
    }

    public func setTheme(_ theme: any LumiUITheme) {
        self.theme = theme
    }
}

@MainActor
public func setTheme(_ theme: any LumiUITheme) {
    LumiUIThemeStore.shared.setTheme(theme)
}

@MainActor
public var currentTheme: any LumiUITheme {
    LumiUIThemeStore.shared.theme
}

@propertyWrapper
@MainActor
public struct LumiTheme: DynamicProperty {
    @ObservedObject private var store = LumiUIThemeStore.shared

    public init() {}

    public var wrappedValue: any LumiUITheme {
        store.theme
    }
}
