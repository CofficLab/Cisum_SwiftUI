import SwiftUI

public struct AppDisclosureCard<Content: View>: View {
    @LumiMotionPreferenceReader private var motionPreference
    @LumiTheme private var theme

    let title: LocalizedStringKey
    let icon: String?
    @ViewBuilder let content: Content

    @State private var isExpanded = false

    public init(title: LocalizedStringKey, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = nil
        self.content = content()
    }

    public init(title: LocalizedStringKey, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }

    public var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            content
                .padding(.top, AppUI.Spacing.sm)
                .appDisclosureContentTransition(preference: motionPreference)
        } label: {
            HStack(spacing: AppUI.Spacing.sm) {
                Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(theme.textSecondary)
                    .frame(width: 12)

                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 14))
                        .foregroundColor(theme.primary)
                }

                Text(title)
                    .font(AppUI.Typography.bodyEmphasized)
                    .foregroundColor(theme.textPrimary)

                Spacer()
            }
            .contentShape(Rectangle())
        }
        .padding(AppUI.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppUI.Radius.sm)
                .fill(AppUI.Material.glass)
        )
        .animation(AppUI.Motion.enabled(AppUI.Motion.disclosure, preference: motionPreference), value: isExpanded)
    }
}

#Preview {
    VStack(spacing: 12) {
        AppDisclosureCard(title: "Advanced Settings") {
            VStack(alignment: .leading, spacing: 8) {
                Text("Setting 1")
                Text("Setting 2")
            }
        }
        AppDisclosureCard(title: "Account Info", icon: "person.circle") {
            Text("User details go here")
        }
    }
    .padding()
    .frame(width: 300)
    .background(Color.gray.opacity(0.15))
}
