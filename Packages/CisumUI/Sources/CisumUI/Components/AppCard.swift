import SwiftUI

/// 通用卡片组件，统一了 elevated/subtle/glass 三种风格。
///
/// 替代了原有的 `GlassCard` 和旧版 `AppCard`，提供：
/// - `.glass`：玻璃拟态（mystic glass 背景 + 渐变边框 + glow），默认风格
/// - `.elevated`：Material 背景 + hover 缩放动画
/// - `.subtle`：低透明度半透明背景
public struct AppCard<Content: View>: View {
    public enum Style {
        /// 玻璃拟态风格：mystic glass 背景 + 渐变边框 + 可选 glow
        case glass
        /// 提升卡片：Material regular 背景 + hover 缩放/阴影动画
        case elevated
        /// 低调卡片：低透明度半透明背景
        case subtle
    }

    let style: Style
    let cornerRadius: CGFloat
    let padding: EdgeInsets
    let showShadow: Bool
    let shadowIntensity: Double
    let glowColor: SwiftUI.Color?
    let borderIntensity: Double
    @LumiTheme private var theme
    @LumiMotionPreferenceReader private var motionPreference
    @Environment(\.colorScheme) private var colorScheme
    @ViewBuilder let content: Content
    @State private var isHovering = false

    public init(
        style: Style = .glass,
        cornerRadius: CGFloat = 16,
        padding: EdgeInsets = EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16),
        showShadow: Bool = true,
        shadowIntensity: Double = 1.0,
        glowColor: SwiftUI.Color? = nil,
        borderIntensity: Double = 0.08,
        @ViewBuilder content: () -> Content
    ) {
        self.style = style
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.showShadow = showShadow
        self.shadowIntensity = shadowIntensity
        self.glowColor = glowColor
        self.borderIntensity = borderIntensity
        self.content = content()
    }

    public var body: some View {
        Group {
            switch style {
            case .glass:
                glassBody
            case .elevated:
                elevatedBody
            case .subtle:
                subtleBody
            }
        }
    }

    // MARK: - Style Bodies

    /// 玻璃拟态风格（原 GlassCard）
    private var glassBody: some View {
        content
            .padding(padding)
            .background(glassBackground)
            .overlay(glassBorder)
            .modifier(CardShadowModifier(showShadow: showShadow, color: shadowColor, radius: shadowRadius, offset: shadowOffset))
            .glowEffect(
                color: glowColor ?? theme.glowAccent,
                radius: glowColor != nil ? 12 : 0,
                intensity: glowColor != nil ? 0.3 : 0
            )
    }

    /// 提升卡片风格（来自原 AppCard，带 hover 动画）
    private var elevatedBody: some View {
        content
            .padding(padding)
            .background(elevatedBackground)
            .overlay(elevatedBorder)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .scaleEffect(isHovering && motionPreference.allowsMotion ? AppUI.Motion.hoverScale : 1.0)
            .shadow(
                color: Color.black.opacity(isHovering ? 0.08 : 0.02),
                radius: isHovering ? 12 : 4,
                y: isHovering ? 6 : 2
            )
            .animation(AppUI.Motion.enabled(AppUI.Motion.hover, preference: motionPreference), value: isHovering)
            .onHover { hovering in
                AppUI.Motion.animate(AppUI.Motion.enabled(AppUI.Motion.hover, preference: motionPreference)) {
                    isHovering = hovering
                }
            }
    }

    /// 低调卡片风格
    private var subtleBody: some View {
        content
            .padding(padding)
            .background(subtleBackground)
            .overlay(subtleBorder)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }

    // MARK: - Glass Style Views

    private var glassBackground: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(DesignTokens.Material.glass)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(DesignTokens.Material.mysticGlass(for: colorScheme))
            )
    }

    private var glassBorder: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .stroke(
                LinearGradient(
                    colors: [
                        SwiftUI.Color.clear,
                        SwiftUI.Color.white.opacity(borderIntensity),
                        SwiftUI.Color.clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 1
            )
    }

    // MARK: - Elevated Style Views

    private var elevatedBackground: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(Material.regularMaterial)
    }

    private var elevatedBorder: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .stroke(theme.textTertiary.opacity(0.12), lineWidth: 1)
    }

    // MARK: - Subtle Style Views

    private var subtleBackground: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(theme.textSecondary.opacity(0.06))
    }

    private var subtleBorder: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .stroke(theme.textTertiary.opacity(0.06), lineWidth: 1)
    }

    // MARK: - Shared Helpers

    private var shadowColor: SwiftUI.Color {
        DesignTokens.Shadow.subtle.opacity(shadowIntensity)
    }

    private var shadowRadius: CGFloat {
        DesignTokens.Shadow.subtleRadius
    }

    private var shadowOffset: CGFloat {
        DesignTokens.Shadow.subtleOffset
    }
}

private struct CardShadowModifier: ViewModifier {
    let showShadow: Bool
    let color: SwiftUI.Color
    let radius: CGFloat
    let offset: CGFloat

    func body(content: Content) -> some View {
        if showShadow {
            content
                .shadow(color: color, radius: radius, x: 0, y: offset)
        } else {
            content
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        AppCard {
            Text("Glass Card (default)")
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        AppCard(style: .elevated) {
            Text("Elevated Card (hover me)")
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        AppCard(style: .subtle) {
            Text("Subtle Card")
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        AppCard(showShadow: false, glowColor: .purple) {
            Text("Glass Card with Glow")
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    .padding()
    .frame(width: 300)
    .background(Color.gray.opacity(0.15))
}
