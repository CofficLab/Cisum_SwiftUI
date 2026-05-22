import SwiftUI

public struct AppEmptyState: View {
    @LumiMotionPreferenceReader private var motionPreference
    @LumiTheme private var theme

    let icon: String
    let title: LocalizedStringKey
    let description: LocalizedStringKey?
    let actionTitle: LocalizedStringKey?
    let action: (() -> Void)?

    @State private var isHovering = false

    public init(
        icon: String,
        title: LocalizedStringKey,
        description: LocalizedStringKey? = nil
    ) {
        self.icon = icon
        self.title = title
        self.description = description
        self.actionTitle = nil
        self.action = nil
    }

    public init(
        icon: String,
        title: LocalizedStringKey,
        description: LocalizedStringKey? = nil,
        actionTitle: LocalizedStringKey,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.title = title
        self.description = description
        self.actionTitle = actionTitle
        self.action = action
    }

    public var body: some View {
        VStack(spacing: AppUI.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(theme.textSecondary.opacity(0.6))
                .scaleEffect(isHovering && motionPreference.allowsMotion ? AppUI.Motion.hoverScale : 1.0)
                .animation(AppUI.Motion.enabled(AppUI.Motion.hover, preference: motionPreference), value: isHovering)
                .onHover { hovering in
                    AppUI.Motion.animate(AppUI.Motion.enabled(AppUI.Motion.hover, preference: motionPreference)) {
                        isHovering = hovering
                    }
                }

            Text(title)
                .font(AppUI.Typography.bodyEmphasized)
                .foregroundColor(theme.textSecondary)

            if let description {
                Text(description)
                    .font(AppUI.Typography.caption1)
                    .foregroundColor(theme.textTertiary)
                    .multilineTextAlignment(.center)
            }

            if let actionTitle, let action {
                AppButton(actionTitle, style: .secondary, size: .small, action: action)
                    .padding(.top, AppUI.Spacing.xs)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(AppUI.Spacing.xl)
    }
}

#Preview {
    VStack(spacing: 16) {
        AppEmptyState(
            icon: "doc.text.magnifyingglass",
            title: "No Results",
            description: "Try adjusting your search terms"
        )
        .frame(height: 200)
    }
    .frame(width: 300)
    .background(Color.gray.opacity(0.15))
}

#Preview("With Action") {
    AppEmptyState(
        icon: "tray",
        title: "Nothing Here Yet",
        description: "Create your first item to get started",
        actionTitle: "Get Started",
        action: {}
    )
    .frame(width: 300, height: 250)
    .background(Color.gray.opacity(0.15))
}
