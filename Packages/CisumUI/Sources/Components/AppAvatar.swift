import SwiftUI

public struct AppAvatar: View {
    let systemImage: String
    let tint: Color
    let backgroundTint: Color
    let size: CGFloat

    @LumiMotionPreferenceReader private var motionPreference
    @State private var isHovering = false

    public init(
        systemImage: String,
        tint: Color,
        backgroundTint: Color,
        size: CGFloat = 24
    ) {
        self.systemImage = systemImage
        self.tint = tint
        self.backgroundTint = backgroundTint
        self.size = size
    }

    public var body: some View {
        Image(systemName: systemImage)
            .font(.system(size: max(10, size * 0.66)))
            .foregroundColor(tint)
            .frame(width: size, height: size)
            .background(backgroundTint)
            .clipShape(Circle())
            .scaleEffect(isHovering && motionPreference.allowsMotion ? AppUI.Motion.hoverScale : 1.0)
            .brightness(isHovering ? 0.08 : 0)
            .shadow(color: tint.opacity(isHovering ? 0.3 : 0), radius: isHovering ? 6 : 0, y: 2)
            .animation(AppUI.Motion.enabled(AppUI.Motion.hover, preference: motionPreference), value: isHovering)
            .onHover { hovering in
                AppUI.Motion.animate(AppUI.Motion.enabled(AppUI.Motion.hover, preference: motionPreference)) {
                    isHovering = hovering
                }
            }
    }
}

public struct AppImageThumbnail: View {
    public enum ShapeStyle {
        case none
        case roundedSmall
        case roundedMedium
        case rounded(CGFloat)
        case circle
        case capsule
    }

    public enum Sizing {
        case stretch
        case fit
        case fill
    }

    let image: Image
    let size: CGSize
    let sizing: Sizing
    let shape: ShapeStyle

    public init(
        image: Image,
        size: CGSize,
        sizing: Sizing = .stretch,
        shape: ShapeStyle = .roundedMedium
    ) {
        self.image = image
        self.size = size
        self.sizing = sizing
        self.shape = shape
    }

    public var body: some View {
        switch shape {
        case .none:
            baseImage
        case .roundedSmall:
            baseImage
                .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.sm, style: .continuous))
        case .roundedMedium:
            baseImage
                .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.md, style: .continuous))
        case let .rounded(radius):
            baseImage
                .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
        case .circle:
            baseImage
                .clipShape(Circle())
        case .capsule:
            baseImage
                .clipShape(Capsule())
        }
    }

    private var baseImage: some View {
        Group {
            switch sizing {
            case .stretch:
                image.resizable()
            case .fit:
                image.resizable().aspectRatio(contentMode: .fit)
            case .fill:
                image.resizable().aspectRatio(contentMode: .fill)
            }
        }
        .frame(width: size.width, height: size.height)
    }
}

// MARK: - 预览

#Preview("AppAvatar") {
    HStack(spacing: 16) {
        AppAvatar(
            systemImage: "person.fill",
            tint: .white,
            backgroundTint: .blue,
            size: 24
        )
        AppAvatar(
            systemImage: "star.fill",
            tint: .white,
            backgroundTint: .orange,
            size: 36
        )
        AppAvatar(
            systemImage: "heart.fill",
            tint: .white,
            backgroundTint: .blue,
            size: 36
        )
    }
    .padding()
}
