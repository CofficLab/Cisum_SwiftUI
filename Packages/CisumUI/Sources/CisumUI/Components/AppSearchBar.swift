import SwiftUI

public struct AppSearchBar: View {
    @LumiTheme private var theme

    @Binding var text: String
    let placeholder: LocalizedStringKey
    let onSubmit: (() -> Void)?

    @FocusState private var isFocused: Bool

    public init(text: Binding<String>, placeholder: LocalizedStringKey) {
        self._text = text
        self.placeholder = placeholder
        self.onSubmit = nil
    }

    public init(text: Binding<String>, placeholder: LocalizedStringKey, onSubmit: @escaping () -> Void) {
        self._text = text
        self.placeholder = placeholder
        self.onSubmit = onSubmit
    }

    public var body: some View {
        HStack(spacing: AppUI.Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14))
                .foregroundColor(theme.textSecondary)

            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
                .font(AppUI.Typography.body)
                .foregroundColor(theme.textPrimary)
                .focused($isFocused)
                .onSubmit {
                    onSubmit?()
                }

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(theme.textSecondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, AppUI.Spacing.md)
        .padding(.vertical, AppUI.Spacing.sm)
        .background(background)
        .cornerRadius(AppUI.Radius.sm)
    }

    @ViewBuilder
    private var background: some View {
        RoundedRectangle(cornerRadius: AppUI.Radius.sm)
            .fill(AppUI.Material.glass)
            .overlay(
                RoundedRectangle(cornerRadius: AppUI.Radius.sm)
                    .stroke(isFocused ? theme.primary.opacity(0.3) : Color.white.opacity(0.08), lineWidth: 1)
            )
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var text = ""
        var body: some View {
            AppSearchBar(text: $text, placeholder: "搜索…")
                .padding(.horizontal)
        }
    }
    return PreviewWrapper()
        .frame(width: 300)
        .padding()
        .background(Color.gray.opacity(0.15))
}
