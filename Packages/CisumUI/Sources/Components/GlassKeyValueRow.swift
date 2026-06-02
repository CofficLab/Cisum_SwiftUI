import SwiftUI

public struct GlassKeyValueRow: View {
    @LumiTheme private var theme

    var label: String
    var value: String
    var labelWidth: CGFloat = 100
    var isValueSelectable: Bool = true
    var valueColor: Color? = nil

    public init(
        label: String,
        value: String,
        labelWidth: CGFloat = 100,
        isValueSelectable: Bool = true,
        valueColor: Color? = nil
    ) {
        self.label = label
        self.value = value
        self.labelWidth = labelWidth
        self.isValueSelectable = isValueSelectable
        self.valueColor = valueColor
    }

    public var body: some View {
        HStack(alignment: .top) {
            Text(label)
                .font(DesignTokens.Typography.subheadline)
                .foregroundColor(theme.textSecondary)
                .frame(width: labelWidth, alignment: .leading)

            Text(":")
                .foregroundColor(theme.textSecondary)

            if isValueSelectable {
                Text(value)
                    .font(DesignTokens.Typography.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(valueColor ?? theme.textPrimary)
                    .textSelection(.enabled)
            } else {
                Text(value)
                    .font(DesignTokens.Typography.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(valueColor ?? theme.textPrimary)
            }

            Spacer()
        }
    }
}

public extension GlassKeyValueRow {
    static func row(_ label: String, value: String) -> some View {
        GlassKeyValueRow(label: label, value: value)
    }

    static func selectable(_ label: String, value: String) -> some View {
        GlassKeyValueRow(label: label, value: value, isValueSelectable: true)
    }
}

#Preview {
    VStack(spacing: 12) {
        GlassKeyValueRow(label: "Status", value: "Active")
        GlassKeyValueRow(label: "Model", value: "gpt-4o", valueColor: .blue)
        GlassKeyValueRow(label: "Tokens", value: "1,234", isValueSelectable: false)
    }
    .padding()
    .frame(width: 300)
    .background(Color.gray.opacity(0.15))
}
