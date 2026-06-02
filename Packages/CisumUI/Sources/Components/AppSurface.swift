import SwiftUI

public enum AppSurfaceStyle {
    case glass
    case glassThick
    case glassUltraThick
    case panel
    case popover
    case toolbar
    case listRow
    case listRowHover
    case listRowSelected
    case subtle
    case custom(Color)
}

private struct AppSurfaceModifier: ViewModifier {
    @LumiTheme private var theme

    let style: AppSurfaceStyle
    let cornerRadius: CGFloat
    let borderColor: Color?
    let lineWidth: CGFloat

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(backgroundFillStyle)
            )
            .overlay(borderOverlay)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }

    private var backgroundFillStyle: AnyShapeStyle {
        switch style {
        case .glass:
            AnyShapeStyle(DesignTokens.Material.glass)
        case .glassThick:
            AnyShapeStyle(DesignTokens.Material.glassThick)
        case .glassUltraThick:
            AnyShapeStyle(DesignTokens.Material.glassUltraThick)
        case .panel:
            AnyShapeStyle(theme.appPanelBackground)
        case .popover:
            AnyShapeStyle(theme.appPopoverBackground)
        case .toolbar:
            AnyShapeStyle(theme.appToolbarBackground)
        case .listRow:
            AnyShapeStyle(theme.appListRowBackground)
        case .listRowHover:
            AnyShapeStyle(theme.appListRowHoverBackground)
        case .listRowSelected:
            AnyShapeStyle(theme.appListRowSelectedBackground)
        case .subtle:
            AnyShapeStyle(theme.textSecondary.opacity(0.06))
        case let .custom(color):
            AnyShapeStyle(color)
        }
    }

    @ViewBuilder
    private var borderOverlay: some View {
        if let borderColor {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(borderColor, lineWidth: lineWidth)
        }
    }
}

public extension View {
    func appSurface(
        style: AppSurfaceStyle = .glass,
        cornerRadius: CGFloat = 16,
        borderColor: Color? = nil,
        lineWidth: CGFloat = 1
    ) -> some View {
        modifier(
            AppSurfaceModifier(
                style: style,
                cornerRadius: cornerRadius,
                borderColor: borderColor,
                lineWidth: lineWidth
            )
        )
    }

    func appClipRounded(_ cornerRadius: CGFloat) -> some View {
        clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

#Preview {
    VStack(spacing: 12) {
        Text("Glass Surface")
            .frame(width: 200, height: 60)
            .appSurface(style: .glass)
        Text("Glass Thick")
            .frame(width: 200, height: 60)
            .appSurface(style: .glassThick)
        Text("Subtle")
            .frame(width: 200, height: 60)
            .appSurface(style: .subtle)
    }
    .padding()
    .frame(width: 300)
    .background(Color.gray.opacity(0.15))
}
