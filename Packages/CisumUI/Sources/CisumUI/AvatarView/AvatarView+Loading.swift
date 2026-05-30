import SwiftUI

extension AvatarView {
    /// 加载中视图组件
    struct LoadingView: View {
        let shape: AvatarViewShape
        let size: CGSize
        let backgroundColor: Color

        init(
            shape: AvatarViewShape = .circle,
            size: CGSize,
            backgroundColor: Color = .blue.opacity(0.1)
        ) {
            self.shape = shape
            self.size = size
            self.backgroundColor = backgroundColor
        }

        var body: some View {
            ProgressView()
                .controlSize(.small)
                .frame(width: size.width, height: size.height)
                .background(backgroundColor)
                .clipShape(shape)
        }
    }
}

// MARK: - Preview

#if DEBUG
    #Preview {
        AvatarView.LoadingView(
            shape: .circle,
            size: CGSize(width: 100, height: 100),
            backgroundColor: .blue.opacity(0.1)
        )
        .magicCentered()
        .frame(width: 200, height: 200)
    }
#endif
