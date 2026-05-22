import SwiftUI

public struct AppRoleBadge: View {
    public enum Style {
        case neutral
        case accent
    }

    let title: String
    let style: Style

    public init(_ title: String, style: Style = .neutral) {
        self.title = title
        self.style = style
    }

    public var body: some View {
        AppTag(
            title,
            style: style == .accent ? .accent : .subtle
        )
    }
}

#Preview {
    HStack(spacing: 8) {
        AppRoleBadge("Admin")
        AppRoleBadge("Editor", style: .accent)
        AppRoleBadge("Viewer")
    }
    .padding()
    .frame(width: 300)
    .background(Color.gray.opacity(0.15))
}
