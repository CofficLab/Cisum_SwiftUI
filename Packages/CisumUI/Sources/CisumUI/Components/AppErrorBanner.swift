import SwiftUI

public struct AppErrorBanner: View {
    @LumiMotionPreferenceReader private var motionPreference
    @LumiTheme private var theme

    let message: LocalizedStringKey
    let retryTitle: LocalizedStringKey?
    let onRetry: (() -> Void)?

    public init(message: LocalizedStringKey) {
        self.message = message
        self.retryTitle = nil
        self.onRetry = nil
    }

    public init(message: LocalizedStringKey, retryTitle: LocalizedStringKey, onRetry: @escaping () -> Void) {
        self.message = message
        self.retryTitle = retryTitle
        self.onRetry = onRetry
    }

    public var body: some View {
        HStack(spacing: AppUI.Spacing.sm) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 14))
                .foregroundColor(theme.error)

            Text(message)
                .font(AppUI.Typography.caption1)
                .foregroundColor(theme.error)
                .lineLimit(nil)

            Spacer()

            if let retryTitle, let onRetry {
                AppButton(retryTitle, style: .ghost, size: .small, action: onRetry)
            }
        }
        .padding(.horizontal, AppUI.Spacing.md)
        .padding(.vertical, AppUI.Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: AppUI.Radius.sm)
                .fill(theme.error.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppUI.Radius.sm)
                .stroke(theme.error.opacity(0.2), lineWidth: 1)
        )
        .appStatusPresentationTransition(preference: motionPreference)
    }
}

#Preview {
    VStack(spacing: 12) {
        AppErrorBanner(message: "Failed to load data")
        AppErrorBanner(
            message: "Connection timeout",
            retryTitle: "Retry",
            onRetry: {}
        )
    }
    .padding()
    .frame(width: 300)
    .background(Color.gray.opacity(0.15))
}
