import SwiftUI

public struct GlassBadge: View {
    @LumiTheme private var theme

    public enum Style {
        case neutral
        case success
        case warning
        case error
        case info
        case glow(SwiftUI.Color)
    }

    let text: LocalizedStringKey
    let style: Style

    public init(text: LocalizedStringKey, style: Style) {
        self.text = text
        self.style = style
    }

    public var body: some View {
        Text(text)
            .font(DesignTokens.Typography.caption1)
            .foregroundColor(foregroundColor)
            .padding(.horizontal, DesignTokens.Spacing.sm)
            .padding(.vertical, DesignTokens.Spacing.xs)
            .background(background)
            .overlay(border)
            .cornerRadius(DesignTokens.Radius.full)
    }

    private var foregroundColor: SwiftUI.Color {
        switch style {
        case .neutral: theme.textSecondary
        case .success: theme.success
        case .warning: theme.warning
        case .error: theme.error
        case .info: theme.info
        case let .glow(color): color
        }
    }

    @ViewBuilder private var background: some View {
        switch style {
        case .neutral:
            RoundedRectangle(cornerRadius: DesignTokens.Radius.full)
                .fill(DesignTokens.Material.glass.opacity(0.15))
        case .success:
            theme.success.opacity(0.15)
        case .warning:
            theme.warning.opacity(0.15)
        case .error:
            theme.error.opacity(0.15)
        case .info:
            theme.info.opacity(0.15)
        case let .glow(color):
            color.opacity(0.2)
        }
    }

    private var borderColor: SwiftUI.Color {
        switch style {
        case .neutral: SwiftUI.Color.white
        case .success: theme.success
        case .warning: theme.warning
        case .error: theme.error
        case .info: theme.info
        case let .glow(color): color
        }
    }

    @ViewBuilder private var border: some View {
        RoundedRectangle(cornerRadius: DesignTokens.Radius.full)
            .stroke(borderColor.opacity(0.2), lineWidth: 1)
    }
}

#Preview {
    VStack(spacing: 8) {
        HStack(spacing: 8) {
            GlassBadge(text: "Neutral", style: .neutral)
            GlassBadge(text: "Success", style: .success)
            GlassBadge(text: "Warning", style: .warning)
        }
        HStack(spacing: 8) {
            GlassBadge(text: "Error", style: .error)
            GlassBadge(text: "Info", style: .info)
            GlassBadge(text: "Glow", style: .glow(.purple))
        }
    }
    .padding()
    .frame(width: 300)
    .background(Color.gray.opacity(0.15))
}
