import SwiftUI

public struct AppSheetPanel<Content: View>: View {
    @LumiTheme private var theme

    let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content
            .padding(AppUI.Spacing.md)
            .frame(maxWidth: .infinity)
            .appSurface(
                style: .custom(theme.elevatedSurface.opacity(0.86)),
                cornerRadius: 8,
                borderColor: theme.divider,
                lineWidth: 1
            )
    }
}

public struct AppSheetIconHeader: View {
    @LumiTheme private var theme

    let systemImage: String
    let title: Text?
    let tint: Color

    public init(systemImage: String, title: LocalizedStringKey? = nil, tint: Color? = nil) {
        self.systemImage = systemImage
        self.title = title.map { Text($0) }
        self.tint = tint ?? .accentColor
    }

    public init(systemImage: String, title: String? = nil, tint: Color? = nil) {
        self.systemImage = systemImage
        self.title = title.map(Text.init)
        self.tint = tint ?? .accentColor
    }

    public var body: some View {
        VStack(spacing: AppUI.Spacing.sm) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [tint.opacity(0.16), theme.primarySecondary.opacity(0.10)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)

                Image(systemName: systemImage)
                    .font(.system(size: 58, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [tint, theme.primarySecondary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .frame(height: 120)

            if let title {
                HStack(spacing: AppUI.Spacing.sm) {
                    Image(systemName: systemImage)
                        .font(.title3)
                        .foregroundColor(tint)
                    title
                        .font(AppUI.Typography.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(theme.textPrimary)
                    Spacer()
                }
            }
        }
    }
}

public struct AppInfoRow: View {
    @LumiTheme private var theme

    let icon: String
    let title: Text
    let description: Text
    let tint: Color

    public init(icon: String, title: String, description: String, tint: Color? = nil) {
        self.icon = icon
        self.title = Text(title)
        self.description = Text(description)
        self.tint = tint ?? .accentColor
    }

    public init(icon: String, title: LocalizedStringKey, description: LocalizedStringKey, tint: Color? = nil) {
        self.icon = icon
        self.title = Text(title)
        self.description = Text(description)
        self.tint = tint ?? .accentColor
    }

    public var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(tint)
                .frame(width: 28, height: 28)

            VStack(alignment: .leading, spacing: 4) {
                title
                    .font(AppUI.Typography.bodyEmphasized)
                    .foregroundColor(theme.textPrimary)

                description
                    .font(AppUI.Typography.caption1)
                    .foregroundColor(theme.textSecondary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

public struct AppStatusBanner: View {
    @LumiTheme private var theme

    public enum Kind {
        case loading
        case success
        case warning
        case error
        case info
    }

    let kind: Kind
    let title: Text
    let message: Text?

    public init(kind: Kind, title: LocalizedStringKey, message: LocalizedStringKey? = nil) {
        self.kind = kind
        self.title = Text(title)
        self.message = message.map { Text($0) }
    }

    public init(kind: Kind, title: String, message: String? = nil) {
        self.kind = kind
        self.title = Text(title)
        self.message = message.map(Text.init)
    }

    public var body: some View {
        HStack(spacing: 12) {
            if kind == .loading {
                ProgressView()
                    .scaleEffect(0.9)
            } else {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(tint)
            }

            VStack(alignment: .leading, spacing: 4) {
                title
                    .font(AppUI.Typography.bodyEmphasized)
                    .foregroundColor(theme.textPrimary)
                if let message {
                    message
                        .font(AppUI.Typography.caption1)
                        .foregroundColor(theme.textSecondary)
                }
            }

            Spacer()
        }
        .padding(AppUI.Spacing.md)
        .appSurface(
            style: .custom(theme.elevatedSurface.opacity(0.86)),
            cornerRadius: 8,
            borderColor: tint.opacity(0.18),
            lineWidth: 1
        )
    }

    private var tint: Color {
        switch kind {
        case .loading, .info: theme.info
        case .success: theme.success
        case .warning: theme.warning
        case .error: theme.error
        }
    }

    private var icon: String {
        switch kind {
        case .loading: "progress.indicator"
        case .success: "checkmark.circle.fill"
        case .warning: "exclamationmark.triangle.fill"
        case .error: "xmark.octagon.fill"
        case .info: "info.circle.fill"
        }
    }
}

public struct AppSheetActionButton: View {
    @LumiTheme private var theme

    let title: Text
    let systemImage: String?
    let role: ButtonRole?
    let action: () -> Void

    public init(
        _ title: LocalizedStringKey,
        systemImage: String? = nil,
        role: ButtonRole? = nil,
        action: @escaping () -> Void
    ) {
        self.title = Text(title)
        self.systemImage = systemImage
        self.role = role
        self.action = action
    }

    public init(
        title: String,
        systemImage: String? = nil,
        role: ButtonRole? = nil,
        action: @escaping () -> Void
    ) {
        self.title = Text(title)
        self.systemImage = systemImage
        self.role = role
        self.action = action
    }

    public var body: some View {
        Button(role: role, action: action) {
            HStack(spacing: 8) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .fontWeight(.semibold)
                }
                title
                    .fontWeight(.semibold)
            }
            .font(AppUI.Typography.bodyEmphasized)
            .foregroundColor(foreground)
            .padding(.horizontal, AppUI.Spacing.md)
            .padding(.vertical, AppUI.Spacing.sm)
            .frame(maxWidth: .infinity)
            .appSurface(
                style: .custom(background),
                cornerRadius: 8,
                borderColor: foreground.opacity(0.18),
                lineWidth: 1
            )
        }
        .buttonStyle(.plain)
    }

    private var foreground: Color {
        role == .destructive ? theme.error : theme.primary
    }

    private var background: Color {
        foreground.opacity(0.10)
    }
}
