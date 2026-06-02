import SwiftUI

public struct AppTag: View {
    @LumiMotionPreferenceReader private var motionPreference
    @LumiTheme private var theme

    public enum Style {
        case subtle
        case accent
    }

    let title: String
    let systemImage: String?
    let style: Style

    @State private var isHovered = false

    public init(
        _ title: String,
        systemImage: String? = nil,
        style: Style = .subtle
    ) {
        self.title = title
        self.systemImage = systemImage
        self.style = style
    }

    public var body: some View {
        HStack(spacing: 4) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.system(size: 10, weight: .medium))
            }
            Text(title)
                .font(DesignTokens.Typography.caption2)
                .lineLimit(1)
        }
        .foregroundStyle(foregroundColor)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.sm, style: .continuous)
                .fill(backgroundColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.sm, style: .continuous)
                .stroke(borderColor, lineWidth: 1)
        )
        .scaleEffect(isHovered && motionPreference.allowsMotion ? AppUI.Motion.hoverScale : 1)
        .shadow(color: hoverShadowColor, radius: isHovered ? 8 : 0, y: isHovered ? 3 : 0)
        .animation(AppUI.Motion.enabled(AppUI.Motion.hover, preference: motionPreference), value: isHovered)
        .onHover { hovering in
            AppUI.Motion.animate(AppUI.Motion.enabled(AppUI.Motion.hover, preference: motionPreference)) {
                isHovered = hovering
            }
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .subtle:
            theme.textSecondary
        case .accent:
            theme.textPrimary
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .subtle:
            isHovered ? theme.textSecondary.opacity(0.16) : theme.textSecondary.opacity(0.10)
        case .accent:
            isHovered ? theme.primary.opacity(0.22) : theme.primary.opacity(0.14)
        }
    }

    private var borderColor: Color {
        switch style {
        case .subtle:
            isHovered ? theme.textSecondary.opacity(0.20) : Color.white.opacity(0.06)
        case .accent:
            isHovered ? theme.primary.opacity(0.40) : theme.primary.opacity(0.25)
        }
    }

    private var hoverShadowColor: Color {
        switch style {
        case .subtle:
            theme.textSecondary.opacity(isHovered ? 0.16 : 0)
        case .accent:
            theme.primary.opacity(isHovered ? 0.20 : 0)
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        HStack(spacing: 8) {
            AppTag("Swift")
            AppTag("SwiftUI", systemImage: "swift")
            AppTag("v5.10", systemImage: "tag")
        }
        HStack(spacing: 8) {
            AppTag("Featured", style: .accent)
            AppTag("New", systemImage: "sparkles", style: .accent)
        }
    }
    .padding()
    .frame(width: 300)
    .background(Color.gray.opacity(0.15))
}
