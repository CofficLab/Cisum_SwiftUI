import SwiftUI

public struct AppLabeledDivider: View {
    @LumiTheme private var theme

    let title: String
    let detail: String?

    public init(title: String, detail: String? = nil) {
        self.title = title
        self.detail = detail
    }

    public var body: some View {
        HStack(spacing: 12) {
            Rectangle()
                .fill(theme.textSecondary.opacity(0.3))
                .frame(height: 1)

            HStack(spacing: 6) {
                Text(title)
                    .font(AppUI.Typography.caption1)
                    .fontWeight(.medium)

                if let detail, !detail.isEmpty {
                    Text(detail)
                        .font(AppUI.Typography.caption2)
                }
            }
            .foregroundColor(theme.textSecondary)

            Rectangle()
                .fill(theme.textSecondary.opacity(0.3))
                .frame(height: 1)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    VStack(spacing: 8) {
        AppLabeledDivider(title: "Section")
        AppLabeledDivider(title: "Advanced", detail: "v2.0")
    }
    .padding()
    .frame(width: 300)
    .background(Color.gray.opacity(0.15))
}
