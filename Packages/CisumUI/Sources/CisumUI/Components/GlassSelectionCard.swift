import SwiftUI

public struct GlassSelectionCard<Content: View>: View {
    @LumiTheme private var theme
    @LumiMotionPreferenceReader private var motionPreference

    var isSelected: Bool
    var showCheckmark: Bool
    var checkmarkColor: Color?
    var selectedBackgroundColor: Color?
    var selectedBorderColor: Color?
    var action: (() -> Void)?

    @ViewBuilder var content: Content
    @State private var isHovering = false

    public init(
        isSelected: Bool = false,
        showCheckmark: Bool = true,
        checkmarkColor: Color? = nil,
        selectedBackgroundColor: Color? = nil,
        selectedBorderColor: Color? = nil,
        action: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.isSelected = isSelected
        self.showCheckmark = showCheckmark
        self.checkmarkColor = checkmarkColor
        self.selectedBackgroundColor = selectedBackgroundColor
        self.selectedBorderColor = selectedBorderColor
        self.action = action
        self.content = content()
    }

    public var body: some View {
        Button(action: {
            action?()
        }) {
            HStack(spacing: DesignTokens.Spacing.md) {
                content
                Spacer()

                if showCheckmark && isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(checkmarkColor ?? selectedColor)
                }
            }
            .padding(DesignTokens.Spacing.md)
            .background(cardBackground)
            .overlay(cardBorder)
            .cornerRadius(DesignTokens.Radius.md)
            .scaleEffect(isHovering && motionPreference.allowsMotion ? AppUI.Motion.hoverScale : 1.0)
            .animation(AppUI.Motion.enabled(AppUI.Motion.selection, preference: motionPreference), value: isSelected)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            AppUI.Motion.animate(AppUI.Motion.enabled(AppUI.Motion.hover, preference: motionPreference)) {
                isHovering = hovering
            }
        }
    }

    @ViewBuilder private var cardBackground: some View {
        if isSelected {
            RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
                .fill(selectedBackgroundColor ?? selectedColor.opacity(0.15))
        } else if isHovering {
            RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
                .fill(DesignTokens.Material.glass.opacity(0.1))
        }
    }

    @ViewBuilder private var cardBorder: some View {
        if isSelected {
            RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
                .stroke(selectedBorderColor ?? selectedColor, lineWidth: 2)
        } else {
            RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
                .stroke(SwiftUI.Color.white.opacity(0.08), lineWidth: 1)
        }
    }

    private var selectedColor: Color {
        checkmarkColor ?? theme.primary
    }
}

public extension GlassSelectionCard {
    func themeStyle(_ color: Color) -> GlassSelectionCard {
        var copy = self
        copy.checkmarkColor = color
        copy.selectedBackgroundColor = color.opacity(0.15)
        copy.selectedBorderColor = color
        return copy
    }
}

#Preview {
    VStack(spacing: 12) {
        GlassSelectionCard(isSelected: true) {
            Label("Selected Option", systemImage: "star.fill")
        }
        GlassSelectionCard(isSelected: false) {
            Label("Unselected Option", systemImage: "circle")
        }
        GlassSelectionCard(isSelected: true, checkmarkColor: .green, selectedBackgroundColor: .green.opacity(0.15), selectedBorderColor: .green) {
            Label("Custom Theme", systemImage: "paintbrush.fill")
        }
    }
    .padding()
    .frame(width: 300)
    .background(Color.gray.opacity(0.15))
}
