import SwiftUI

extension AvatarView {
    /// 默认图标显示视图组件
    struct DefaultIconView: View {
        let url: URL
        let shape: AvatarViewShape
        let size: CGSize
        let backgroundColor: Color
        
        var padding: CGFloat {
            if case .circle = shape {
                return self.size.width * 0.2
            }

            return self.size.width * 0.0
        }

        init(
            url: URL,
            shape: AvatarViewShape = .circle,
            size: CGSize,
            backgroundColor: Color = .blue.opacity(0.1)
        ) {
            self.url = url
            self.shape = shape
            self.size = size
            self.backgroundColor = backgroundColor
        }

        var body: some View {
            url.fastDefaultImage
                .resizable()
                .scaledToFit()
                .foregroundStyle(.secondary)
                .padding(padding)
                .frame(width: size.width, height: size.height)
                .background(backgroundColor)
                .clipShape(shape)
        }
    }
}

// MARK: - Preview

#if DEBUG
    #Preview {
        AvatarView.DefaultIconView(
            url: URL(fileURLWithPath: "/tmp/test.pdf"),
            shape: .circle,
            size: CGSize(width: 100, height: 100),
            backgroundColor: .blue.opacity(0.1)
        )
        .magicCentered()
        .frame(width: 200, height: 200)
    }
#endif
