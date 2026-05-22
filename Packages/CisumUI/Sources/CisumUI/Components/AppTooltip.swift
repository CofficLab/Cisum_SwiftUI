import SwiftUI

public extension View {
    func appTooltip(_ text: LocalizedStringKey) -> some View {
        help(text)
    }

    func appTooltip(_ text: LocalizedStringKey, shortcut: KeyboardShortcut?) -> some View {
        Group {
            if let shortcut {
                let shortcutStr = shortcutText(shortcut)
                let tooltipText = Text("\(text) (\(shortcutStr))")
                help(tooltipText)
            } else {
                help(text)
            }
        }
    }

    private func shortcutText(_ shortcut: KeyboardShortcut) -> String {
        var parts: [String] = []

        if shortcut.modifiers.contains(.command) { parts.append("⌘") }
        if shortcut.modifiers.contains(.option) { parts.append("⌥") }
        if shortcut.modifiers.contains(.control) { parts.append("⌃") }
        if shortcut.modifiers.contains(.shift) { parts.append("⇧") }

        parts.append(shortcut.key)

        return parts.joined()
    }
}

extension KeyboardShortcut {
    var key: String {
        switch self {
        case .defaultAction: "↩"
        case .cancelAction: "⌘."
        default: ""
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        Text("Hover me")
            .appTooltip("Simple tooltip")
        Text("With shortcut")
            .appTooltip("Save file", shortcut: .init("s", modifiers: .command))
    }
    .padding()
    .frame(width: 300)
    .background(Color.gray.opacity(0.15))
}
