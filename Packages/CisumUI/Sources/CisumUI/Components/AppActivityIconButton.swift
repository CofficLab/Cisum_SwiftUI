import SwiftUI

public struct AppActivityIconButton: View {
    @LumiTheme private var theme
    @LumiMotionPreferenceReader private var motionPreference

    let systemImage: String
    let label: String
    let isActive: Bool
    let activeTint: Color?
    let inactiveTint: Color?
    let hoverTint: Color?
    let indicatorTint: Color?
    let action: () -> Void

    @State private var isHovered = false

    public init(
        systemImage: String,
        label: String,
        isActive: Bool = false,
        activeTint: Color? = nil,
        inactiveTint: Color? = nil,
        hoverTint: Color? = nil,
        indicatorTint: Color? = nil,
        action: @escaping () -> Void
    ) {
        self.systemImage = systemImage
        self.label = label
        self.isActive = isActive
        self.activeTint = activeTint
        self.inactiveTint = inactiveTint
        self.hoverTint = hoverTint
        self.indicatorTint = indicatorTint
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            ZStack(alignment: .leading) {
                if isActive {
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .fill(indicatorTint ?? theme.primary)
                        .frame(width: 2.5, height: 20)
                        .transition(.opacity.combined(with: .scale(scale: 0.8, anchor: .leading)))
                }

                Image(systemName: systemImage)
                    .font(.system(size: 18))
                    .foregroundColor(iconColor)
                    .frame(maxWidth: .infinity, minHeight: 40)
                    .contentShape(Rectangle())
                    .scaleEffect(isHovered && !isActive && motionPreference.allowsMotion ? LumiMotion.hoverScale : 1.0)
            }
        }
        .buttonStyle(.plain)
        .help(label)
        .animation(LumiMotion.enabled(LumiMotion.selection, preference: motionPreference), value: isActive)
        .onHover { hovering in
            LumiMotion.animate(LumiMotion.enabled(LumiMotion.hover, preference: motionPreference)) {
                isHovered = hovering
            }
        }
    }

    private var iconColor: Color {
        if isActive {
            activeTint ?? theme.textPrimary
        } else if isHovered {
            hoverTint ?? theme.textPrimary.opacity(0.8)
        } else {
            inactiveTint ?? theme.textSecondary
        }
    }
}

#Preview {
    VStack(spacing: 4) {
        AppActivityIconButton(systemImage: "folder", label: "Projects", isActive: true) {}
        AppActivityIconButton(systemImage: "magnifyingglass", label: "Search") {}
    }
    .frame(width: 48)
    .padding(.vertical, 8)
    .background(Color.gray.opacity(0.15))
}
