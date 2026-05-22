import SwiftUI

public struct AppSettingsSection<Content: View>: View {
    @LumiTheme private var theme

    let title: Text?
    let subtitle: Text?
    let spacing: CGFloat
    let content: Content

    public init(
        title: String? = nil,
        subtitle: String? = nil,
        spacing: CGFloat = 8,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title.map(Text.init)
        self.subtitle = subtitle.map(Text.init)
        self.spacing = spacing
        self.content = content()
    }

    public init(
        _ title: LocalizedStringKey,
        subtitle: LocalizedStringKey? = nil,
        spacing: CGFloat = 8,
        @ViewBuilder content: () -> Content
    ) {
        self.title = Text(title)
        self.subtitle = subtitle.map { Text($0) }
        self.spacing = spacing
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            if title != nil || subtitle != nil {
                VStack(alignment: .leading, spacing: 2) {
                    if let title {
                        title
                            .font(.appSectionTitle)
                            .foregroundColor(theme.textPrimary)
                    }
                    if let subtitle {
                        subtitle
                            .font(.appCaption)
                            .foregroundColor(theme.textSecondary)
                    }
                }
                .padding(.horizontal, 2)
            }

            VStack(spacing: 6) {
                content
            }
        }
    }
}

public struct AppSettingsRow<Content: View>: View {
    @LumiTheme private var theme
    @LumiMotionPreferenceReader private var motionPreference

    let isSelected: Bool
    let isHighlighted: Bool
    let horizontalPadding: CGFloat
    let verticalPadding: CGFloat
    let content: Content

    @State private var isHovered = false

    public init(
        isSelected: Bool = false,
        isHighlighted: Bool = false,
        horizontalPadding: CGFloat = 8,
        verticalPadding: CGFloat = 8,
        @ViewBuilder content: () -> Content
    ) {
        self.isSelected = isSelected
        self.isHighlighted = isHighlighted
        self.horizontalPadding = horizontalPadding
        self.verticalPadding = verticalPadding
        self.content = content()
    }

    public var body: some View {
        content
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .appSurface(
                style: surfaceStyle,
                cornerRadius: 8,
                borderColor: borderColor,
                lineWidth: 1
            )
            .scaleEffect(isHovered && motionPreference.allowsMotion ? AppUI.Motion.rowHoverScale : 1.0)
            .onHover { hovering in
                AppUI.Motion.animate(AppUI.Motion.enabled(AppUI.Motion.hover, preference: motionPreference)) {
                    isHovered = hovering
                }
            }
    }

    private var surfaceStyle: AppSurfaceStyle {
        if isHighlighted {
            return .custom(theme.primary.opacity(0.06))
        }
        if isSelected {
            return .listRowSelected
        }
        if isHovered {
            return .listRowHover
        }
        return .listRow
    }

    private var borderColor: Color? {
        if isSelected {
            return theme.appSelectedBorder
        }
        if isHovered {
            return theme.appHoverBorder
        }
        return nil
    }
}

public struct AppSettingsToggleRow: View {
    @LumiTheme private var theme

    let title: Text
    let description: Text?
    let systemImage: String?
    @Binding var isOn: Bool

    public init(
        _ title: LocalizedStringKey,
        description: LocalizedStringKey? = nil,
        systemImage: String? = nil,
        isOn: Binding<Bool>
    ) {
        self.title = Text(title)
        self.description = description.map { Text($0) }
        self.systemImage = systemImage
        self._isOn = isOn
    }

    public init(
        _ title: String,
        description: String? = nil,
        systemImage: String? = nil,
        isOn: Binding<Bool>
    ) {
        self.title = Text(title)
        self.description = description.map(Text.init)
        self.systemImage = systemImage
        self._isOn = isOn
    }

    public var body: some View {
        AppSettingsRow {
            HStack(spacing: 12) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.appCallout)
                        .foregroundColor(theme.primary)
                        .frame(width: 24)
                }

                VStack(alignment: .leading, spacing: 2) {
                    title
                        .font(.appBody)
                        .foregroundColor(theme.textPrimary)

                    if let description {
                        description
                            .font(.appCaption)
                            .foregroundColor(theme.textSecondary)
                    }
                }

                Spacer()

                Toggle("", isOn: $isOn)
                    .labelsHidden()
                    .toggleStyle(.switch)
                    .controlSize(.small)
            }
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var enabled = true

        var body: some View {
            AppSettingsSection(title: "Settings", subtitle: "Shared section styling") {
                AppSettingsRow(isSelected: true) {
                    Text("Selected row")
                        .font(.appBody)
                }
                AppSettingsToggleRow("Enable feature", description: "Uses LumiUI theme tokens", systemImage: "switch.2", isOn: $enabled)
            }
            .padding()
            .frame(width: 360)
        }
    }

    return PreviewWrapper()
}
