import SwiftUI

public struct AppListRow<Content: View>: View {
    @LumiTheme private var theme
    @LumiMotionPreferenceReader private var motionPreference

    let isSelected: Bool
    let action: (() -> Void)?
    let content: Content

    @State private var isHovered = false

    public init(isSelected: Bool = false, @ViewBuilder content: () -> Content) {
        self.isSelected = isSelected
        self.action = nil
        self.content = content()
    }

    public init(isSelected: Bool, action: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.isSelected = isSelected
        self.action = action
        self.content = content()
    }

    public var body: some View {
        Button(action: { action?() }) {
            content
                .padding(.horizontal, AppUI.Spacing.md)
                .padding(.vertical, AppUI.Spacing.sm)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(rowBackground)
                .overlay(rowBorder)
                .cornerRadius(AppUI.Radius.sm)
                .scaleEffect(isHovered && motionPreference.allowsMotion ? AppUI.Motion.rowHoverScale : 1.0)
                .shadow(color: Color.black.opacity(isHovered ? 0.06 : 0), radius: isHovered ? 8 : 0, y: isHovered ? 3 : 0)
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
        .onHover { hovering in
            AppUI.Motion.animate(AppUI.Motion.enabled(AppUI.Motion.hover, preference: motionPreference)) {
                isHovered = hovering
            }
        }
    }

    @ViewBuilder
    private var rowBackground: some View {
        Group {
            if isSelected {
                theme.primary.opacity(0.12)
            } else if isHovered {
                Color.white.opacity(0.08)
            } else {
                Color.clear
            }
        }
    }

    @ViewBuilder
    private var rowBorder: some View {
        if isSelected {
            RoundedRectangle(cornerRadius: AppUI.Radius.sm)
                .stroke(theme.primary.opacity(0.3), lineWidth: 1)
        } else if isHovered {
            RoundedRectangle(cornerRadius: AppUI.Radius.sm)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        }
    }
}

#Preview {
    VStack(spacing: 4) {
        AppListRow(isSelected: true) {
            Text("Selected Item")
        }
        AppListRow {
            Text("Normal Item")
        }
        AppListRow(isSelected: false, action: {}) {
            HStack {
                Image(systemName: "star")
                Text("With Action")
            }
        }
    }
    .frame(width: 300)
    .padding()
    .background(Color.gray.opacity(0.15))
}
