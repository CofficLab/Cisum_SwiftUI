import SwiftUI

public struct AppButton: View {
    @LumiTheme private var theme
    @LumiMotionPreferenceReader private var motionPreference
    @State private var isHovered = false

    public enum Style {
        case primary
        case secondary
        case ghost
        case tonal
        case destructive
    }

    public enum Size {
        case small
        case medium
    }

    struct Metrics: Equatable {
        let horizontalPadding: CGFloat
        let verticalPadding: CGFloat
    }

    let title: Text
    let systemImage: String?
    let showsTitle: Bool
    let style: Style
    let size: Size
    let fillsWidth: Bool
    let isDisabled: Bool
    let action: () -> Void

    public init(
        _ title: LocalizedStringKey,
        systemImage: String? = nil,
        style: Style = .secondary,
        size: Size = .medium,
        fillsWidth: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = Text(title)
        self.systemImage = systemImage
        self.style = style
        self.size = size
        self.showsTitle = true
        self.fillsWidth = fillsWidth
        self.isDisabled = false
        self.action = action
    }

    public init(
        _ title: String,
        systemImage: String? = nil,
        style: Style = .secondary,
        size: Size = .medium,
        fillsWidth: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = Text(title)
        self.systemImage = systemImage
        self.style = style
        self.size = size
        self.showsTitle = true
        self.fillsWidth = fillsWidth
        self.isDisabled = false
        self.action = action
    }

    /// 本地化标题（String Catalog table）。
    public init(
        localized title: String,
        table: String,
        systemImage: String? = nil,
        style: Style = .secondary,
        size: Size = .medium,
        fillsWidth: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = Text(String(localized: String.LocalizationValue(title), table: table))
        self.systemImage = systemImage
        self.showsTitle = true
        self.style = style
        self.size = size
        self.fillsWidth = fillsWidth
        self.isDisabled = false
        self.action = action
    }

    /// 仅图标按钮。
    public init(
        systemImage: String,
        style: Style = .ghost,
        size: Size = .small,
        action: @escaping () -> Void
    ) {
        self.title = Text(verbatim: "")
        self.systemImage = systemImage
        self.showsTitle = false
        self.style = style
        self.size = size
        self.fillsWidth = false
        self.isDisabled = false
        self.action = action
    }

    private init(
        title: Text,
        systemImage: String?,
        showsTitle: Bool,
        style: Style,
        size: Size,
        fillsWidth: Bool,
        isDisabled: Bool,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.showsTitle = showsTitle
        self.style = style
        self.size = size
        self.fillsWidth = fillsWidth
        self.isDisabled = isDisabled
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let systemImage {
                    Image(systemName: systemImage)
                }
                if showsTitle {
                    title
                }
            }
            .font(font)
            .foregroundStyle(foregroundColor)
            .padding(.horizontal, metrics.horizontalPadding)
            .padding(.vertical, metrics.verticalPadding)
            .frame(maxWidth: fillsWidth ? .infinity : nil)
            .background(background)
            .overlay(border)
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.sm, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.5 : 1.0)
        .scaleEffect(isEffectivelyHovered && motionPreference.allowsMotion ? AppUI.Motion.hoverScale : 1.0)
        .onHover { hovering in
            AppUI.Motion.animate(AppUI.Motion.enabled(AppUI.Motion.hover, preference: motionPreference)) {
                isHovered = hovering && !isDisabled
            }
        }
    }

    /// Returns a new button with the disabled state set.
    public func disabled(_ isDisabled: Bool) -> AppButton {
        AppButton(
            title: title,
            systemImage: systemImage,
            showsTitle: showsTitle,
            style: style,
            size: size,
            fillsWidth: fillsWidth,
            isDisabled: isDisabled,
            action: action
        )
    }

    var metrics: Metrics {
        switch size {
        case .small:
            Metrics(horizontalPadding: 10, verticalPadding: 6)
        case .medium:
            Metrics(horizontalPadding: 14, verticalPadding: 10)
        }
    }

    private var font: Font {
        switch size {
        case .small:
            DesignTokens.Typography.caption1
        case .medium:
            DesignTokens.Typography.bodyEmphasized
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary:
            .white
        case .secondary:
            theme.textPrimary
        case .ghost:
            theme.primary
        case .tonal:
            theme.textSecondary
        case .destructive:
            theme.error
        }
    }

    private var background: some View {
        Group {
            switch style {
            case .primary:
                RoundedRectangle(cornerRadius: DesignTokens.Radius.sm, style: .continuous)
                    .fill(isEffectivelyHovered ? theme.primary.opacity(0.85) : theme.primary.opacity(0.5))
            case .secondary:
                RoundedRectangle(cornerRadius: DesignTokens.Radius.sm, style: .continuous)
                    .fill(isEffectivelyHovered ? Color.white.opacity(0.12) : theme.primarySecondary)
            case .ghost:
                RoundedRectangle(cornerRadius: DesignTokens.Radius.sm, style: .continuous)
                    .fill(isEffectivelyHovered ? theme.primary : Color.clear)
            case .tonal:
                RoundedRectangle(cornerRadius: DesignTokens.Radius.sm, style: .continuous)
                    .fill(isEffectivelyHovered ? theme.textSecondary.opacity(0.18) : theme.textSecondary.opacity(0.10))
            case .destructive:
                RoundedRectangle(cornerRadius: DesignTokens.Radius.sm, style: .continuous)
                    .fill(isEffectivelyHovered ? theme.error.opacity(0.35) : theme.error.opacity(0.22))
            }
        }
    }

    private var isEffectivelyHovered: Bool {
        isHovered && !isDisabled
    }

    private var border: some View {
        Group {
            switch style {
            case .secondary:
                RoundedRectangle(cornerRadius: DesignTokens.Radius.sm, style: .continuous)
                    .stroke(
                        isEffectivelyHovered ? Color.white.opacity(0.20) : Color.white.opacity(0.12),
                        lineWidth: 1
                    )
            case .ghost:
                RoundedRectangle(cornerRadius: DesignTokens.Radius.sm, style: .continuous)
                    .stroke(
                        isEffectivelyHovered ? theme.primary.opacity(0.45) : theme.primary.opacity(0.25),
                        lineWidth: 1
                    )
            case .destructive:
                RoundedRectangle(cornerRadius: DesignTokens.Radius.sm, style: .continuous)
                    .stroke(
                        isEffectivelyHovered ? theme.error.opacity(0.55) : theme.error.opacity(0.35),
                        lineWidth: 1
                    )
            default:
                EmptyView()
            }
        }
    }
}

#Preview {
    HStack {
        Spacer()
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                AppButton("Primary", style: .primary) {}
                AppButton("Secondary", style: .secondary) {}
            }
            HStack(spacing: 8) {
                AppButton("Ghost", style: .ghost) {}
                AppButton("Tonal", style: .tonal) {}
                AppButton("Destructive", style: .destructive) {}
            }
            HStack(spacing: 8) {
                AppButton("Small", systemImage: "star", style: .primary, size: .small) {}
                AppButton("With Icon", systemImage: "gearshape", style: .secondary) {}
            }
        }
        Spacer()
    }
    .padding()
    .frame(maxHeight: .infinity)
    .frame(maxWidth: .infinity)
    .background(Color.gray.opacity(0.15))
}
