import SwiftUI

public struct GlassSectionHeader: View {
    @LumiTheme private var theme

    var icon: String
    var title: String
    var subtitle: String? = nil
    var iconColor: Color? = nil
    var spacing: CGFloat

    public init(
        icon: String,
        title: String,
        subtitle: String? = nil,
        iconColor: Color? = nil,
        spacing: CGFloat = 16
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.iconColor = iconColor
        self.spacing = spacing
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            HStack(spacing: DesignTokens.Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(iconColor ?? theme.primary)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    Text(title)
                        .font(DesignTokens.Typography.bodyEmphasized)
                        .foregroundColor(theme.textPrimary)

                    if let subtitle {
                        Text(subtitle)
                            .font(DesignTokens.Typography.caption1)
                            .foregroundColor(theme.textTertiary)
                    }
                }

                Spacer()
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        GlassSectionHeader(icon: "gearshape", title: "设置")
        GlassSectionHeader(
            icon: "person.circle",
            title: "账户",
            subtitle: "管理你的个人资料",
            iconColor: .blue
        )
        GlassSectionHeader(
            icon: "bell.fill",
            title: "通知",
            subtitle: "推送、邮件和短信",
            iconColor: .orange
        )
    }
    .padding()
    .frame(width: 300)
    .background(Color.gray.opacity(0.15))
}
