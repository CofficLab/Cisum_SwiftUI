import SwiftUI

/// 标题对齐方式枚举。
public enum MagicSettingSectionTitleAlignment {
    case leading
    case center
    case trailing
}

/// MagicKit 设置分组的 CisumUI 兼容实现。
public struct MagicSettingSection<Content: View>: View {
    let title: String?
    let titleAlignment: MagicSettingSectionTitleAlignment
    let content: Content

    public init(
        title: String? = nil,
        titleAlignment: MagicSettingSectionTitleAlignment = .leading,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.titleAlignment = titleAlignment
        self.content = content()
    }

    public var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                if let title {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: alignment)
                        .padding(.leading, titleAlignment == .leading ? 4 : 0)
                        .padding(.trailing, titleAlignment == .trailing ? 4 : 0)
                }

                content
                    .padding(.leading, 4)
            }
            .padding(.vertical, 12)
        }
    }

    private var alignment: Alignment {
        switch titleAlignment {
        case .leading:
            return .leading
        case .center:
            return .center
        case .trailing:
            return .trailing
        }
    }
}

/// MagicKit 设置行的 CisumUI 兼容实现。
public struct MagicSettingRow<Content: View>: View {
    let title: String
    let description: String?
    let icon: String?
    let content: Content
    let action: (() -> Void)?

    @State private var isHovered = false
    @State private var isPressed = false

    public init(
        title: String,
        description: String? = nil,
        icon: String? = nil,
        action: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.description = description
        self.icon = icon
        self.action = action
        self.content = content()
    }

    public var body: some View {
        Button(action: {
            action?()
        }) {
            HStack(alignment: .center, spacing: 16) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundStyle(.secondary)
                        .frame(width: 24, height: 24)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.body)

                    if let description {
                        Text(description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                content
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background {
            #if os(macOS)
                RoundedRectangle(cornerRadius: 6)
                    .fill(
                        isPressed
                            ? Color.primary.opacity(0.1)
                            : isHovered ? Color.primary.opacity(0.05) : Color.clear
                    )
                    .animation(.easeOut(duration: 0.15), value: isHovered)
                    .animation(.easeOut(duration: 0.1), value: isPressed)
            #endif
        }
        #if os(macOS)
            .onHover { hovering in
                isHovered = hovering
            }
            .pressAction { isPressed in
                self.isPressed = isPressed
            }
        #endif
    }
}

private extension View {
    func pressAction(onPress: @escaping (Bool) -> Void) -> some View {
        modifier(PressActionModifier(onPress: onPress))
    }
}

private struct PressActionModifier: ViewModifier {
    let onPress: (Bool) -> Void

    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 10)
                    .onChanged { _ in onPress(true) }
                    .onEnded { _ in onPress(false) }
            )
    }
}

#Preview {
    MagicSettingSection(title: "General") {
        MagicSettingRow(title: "Library Size", description: "iCloud Drive", icon: "folder") {
            Text("90.9 MB")
                .font(.footnote)
        }

        MagicSettingRow(title: "Open Library", description: "View in Finder", icon: "arrow.right.circle") {
            Image(systemName: "arrow.right.circle")
        }
    }
    .padding()
    .frame(width: 420)
}
