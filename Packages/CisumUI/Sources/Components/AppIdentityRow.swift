import SwiftUI

public struct AppIdentityRow: View {
    @LumiTheme private var theme

    let title: String
    let metadata: [String]
    let titleColor: Color?
    let metadataColor: Color?

    public init(
        title: String,
        metadata: [String] = [],
        titleColor: Color? = nil,
        metadataColor: Color? = nil
    ) {
        self.title = title
        self.metadata = metadata.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        self.titleColor = titleColor
        self.metadataColor = metadataColor
    }

    public var body: some View {
        HStack(alignment: .center, spacing: 4) {
            Text(title)
                .font(DesignTokens.Typography.caption1)
                .fontWeight(.medium)
                .foregroundColor(titleColor ?? theme.textPrimary)
                .lineLimit(1)

            ForEach(Array(metadata.enumerated()), id: \.offset) { _, item in
                Text("·")
                    .foregroundColor(metadataColor ?? theme.textSecondary)
                Text(item)
                    .font(DesignTokens.Typography.caption2)
                    .foregroundColor(metadataColor ?? theme.textSecondary)
                    .lineLimit(1)
            }
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        AppIdentityRow(
            title: "GPT-4",
            metadata: ["OpenAI", "2024"]
        )
        AppIdentityRow(
            title: "Claude",
            metadata: ["Anthropic"],
            titleColor: .purple
        )
        AppIdentityRow(
            title: "Standalone"
        )
    }
    .padding()
    .frame(width: 300)
    .background(Color.gray.opacity(0.15))
}
