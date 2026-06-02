import SwiftUI

public struct DropOverlayCard: View {
    @LumiTheme private var theme

    let icon: String
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey

    public init(
        icon: String = "folder.badge.plus",
        title: LocalizedStringKey,
        subtitle: LocalizedStringKey
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
    }

    public var body: some View {
        ZStack {
            Rectangle()
                .fill(DesignTokens.Material.glass)
                .overlay(Color.black.opacity(0.12))
                .overlay(
                    Rectangle()
                        .stroke(
                            theme.primary.opacity(0.35),
                            style: StrokeStyle(lineWidth: 2, dash: [10, 8])
                        )
                )

            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(theme.primary)
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.Radius.md, style: .continuous)
                    .stroke(Color.white.opacity(0.35), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.25), radius: 16, x: 0, y: 8)
        }
        .allowsHitTesting(false)
    }
}

#Preview {
    DropOverlayCard(
        icon: "folder.badge.plus",
        title: "拖放文件到这里",
        subtitle: "支持图片、文档、代码文件等"
    )
    .frame(width: 400, height: 300)
    .padding()
    .background(Color.gray.opacity(0.15))
}
