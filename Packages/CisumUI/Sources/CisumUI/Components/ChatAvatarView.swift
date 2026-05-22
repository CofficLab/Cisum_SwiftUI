import SwiftUI

public enum ChatAvatarKind {
    case assistant
    case user
    case tool
    case status
    case error
    case system
}

public struct ChatAvatarView: View {
    let kind: ChatAvatarKind

    public init(kind: ChatAvatarKind) {
        self.kind = kind
    }

    public var body: some View {
        switch kind {
        case .assistant:
            AvatarView.assistant
        case .user:
            AvatarView.user
        case .tool:
            AvatarView.tool
        case .status:
            AvatarView.status
        case .error:
            AvatarView.error
        case .system:
            AvatarView.system
        }
    }
}

@MainActor
public enum AvatarView {
    public static var assistant: some View {
        AppAvatar(
            systemImage: "cpu",
            tint: Color(hex: "7C6FFF"),
            backgroundTint: Color(hex: "7C6FFF").opacity(0.1)
        )
    }

    public static var user: some View {
        AppAvatar(
            systemImage: "person.fill",
            tint: Color(hex: "0A84FF"),
            backgroundTint: Color(hex: "0A84FF").opacity(0.1)
        )
    }

    public static var tool: some View {
        AppAvatar(
            systemImage: "gearshape.2.fill",
            tint: Color(hex: "98989E"),
            backgroundTint: Color(hex: "98989E").opacity(0.1)
        )
    }

    public static var status: some View {
        AppAvatar(
            systemImage: "sparkles",
            tint: Color(hex: "FF9F0A"),
            backgroundTint: Color(hex: "FF9F0A").opacity(0.12)
        )
    }

    public static var error: some View {
        AppAvatar(
            systemImage: "exclamationmark.triangle.fill",
            tint: Color(hex: "FF453A"),
            backgroundTint: Color(hex: "FF453A").opacity(0.12)
        )
    }

    public static var system: some View {
        AppAvatar(
            systemImage: "bolt.shield.fill",
            tint: Color.adaptive(light: "6B6B7B", dark: "EBEBF5"),
            backgroundTint: Color.adaptive(light: "6B6B7B", dark: "EBEBF5").opacity(0.10)
        )
    }
}

#Preview {
    HStack(spacing: 16) {
        ChatAvatarView(kind: .assistant)
        ChatAvatarView(kind: .user)
        ChatAvatarView(kind: .tool)
        ChatAvatarView(kind: .status)
        ChatAvatarView(kind: .error)
        ChatAvatarView(kind: .system)
    }
    .padding()
    .frame(width: 300)
    .background(Color.gray.opacity(0.15))
}
