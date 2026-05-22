import SwiftUI

// MARK: - App Chrome Theme

/// IDE / 应用外壳主题协议（工作区、侧栏、全局背景等）。
/// 插件主题实现此协议；组件库语义色见 ``LumiUITheme``。
public protocol LumiAppChromeTheme {
    var identifier: String { get }
    var displayName: String { get }
    var description: String { get }
    var iconName: String { get }
    var iconColor: Color { get }
    var isDarkTheme: Bool { get }
    var followsSystemAppearance: Bool { get }

    func accentColors() -> (primary: Color, secondary: Color, tertiary: Color)
    func atmosphereColors() -> (deep: Color, medium: Color, light: Color)
    func glowColors() -> (subtle: Color, medium: Color, intense: Color)

    func backgroundGradient() -> LinearGradient
    func glowGradient() -> RadialGradient

    func workspaceBackgroundColor() -> Color
    func workspaceTextColor() -> Color
    func workspaceSecondaryTextColor() -> Color
    func workspaceTertiaryTextColor() -> Color

    func makeGlobalBackground(proxy: GeometryProxy) -> AnyView
}

// MARK: - Default Implementations

public extension LumiAppChromeTheme {
    var isDarkTheme: Bool { true }
    var followsSystemAppearance: Bool { false }

    func workspaceBackgroundColor() -> Color {
        atmosphereColors().deep
    }

    func workspaceTextColor() -> Color {
        isDarkTheme ? Color.white : Color(hex: "1C1C1E")
    }

    func workspaceSecondaryTextColor() -> Color {
        isDarkTheme ? Color.white.opacity(0.6) : Color(hex: "6B6B7B")
    }

    func workspaceTertiaryTextColor() -> Color {
        isDarkTheme ? Color.white.opacity(0.4) : Color(hex: "98989E")
    }

    func backgroundGradient() -> LinearGradient {
        let colors = atmosphereColors()
        return LinearGradient(
            colors: [colors.medium, colors.deep, colors.light],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    func glowGradient() -> RadialGradient {
        let colors = glowColors()
        return RadialGradient(
            colors: [colors.medium, colors.subtle, Color.clear],
            center: .center,
            startRadius: 0,
            endRadius: 250
        )
    }

    func makeGlobalBackground(proxy: GeometryProxy) -> AnyView {
        AnyView(
            ZStack {
                backgroundGradient()

                Circle()
                    .fill(glowGradient())
                    .frame(width: 520, height: 520)
                    .blur(radius: 140)
                    .position(x: proxy.size.width, y: 0)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .clipped()
            .allowsHitTesting(false)
        )
    }
}
