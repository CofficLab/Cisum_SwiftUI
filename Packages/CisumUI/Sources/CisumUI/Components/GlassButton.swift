import SwiftUI

@available(*, deprecated, message: "Use AppButton instead")
public struct GlassButton: View {
    public enum Style {
        case primary
        case secondary
        case ghost
        case danger
    }

    private let appButton: AppButton

    public init(
        title: LocalizedStringKey,
        tableName: String? = nil,
        style: Style,
        action: @escaping () -> Void
    ) {
        appButton = AppButton(
            title,
            style: Self.mapStyle(style),
            fillsWidth: true,
            action: action
        )
    }

    public init(
        title: String,
        tableName: String? = nil,
        style: Style,
        action: @escaping () -> Void
    ) {
        if let tableName {
            appButton = AppButton(
                localized: title,
                table: tableName,
                style: Self.mapStyle(style),
                fillsWidth: true,
                action: action
            )
        } else {
            appButton = AppButton(
                title,
                style: Self.mapStyle(style),
                fillsWidth: true,
                action: action
            )
        }
    }

    public init(systemImage: String, style: Style, action: @escaping () -> Void) {
        appButton = AppButton(systemImage: systemImage, style: Self.mapStyle(style), action: action)
    }

    public var body: some View {
        appButton
    }

    private static func mapStyle(_ style: Style) -> AppButton.Style {
        switch style {
        case .primary: .primary
        case .secondary: .secondary
        case .ghost: .ghost
        case .danger: .destructive
        }
    }
}
