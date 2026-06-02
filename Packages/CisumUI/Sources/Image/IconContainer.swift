import SwiftUI

public struct IconContainer<Content: View>: View {
    private let content: Content
    private let fixedSize: CGFloat?
    private let shape: IconShape

    public init(
        size: CGFloat? = nil,
        shape: IconShape = .rectangle,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.fixedSize = size
        self.shape = shape
    }

    public var body: some View {
        let contentView: some View = if let size = fixedSize {
            AnyView(content.frame(width: size, height: size))
        } else {
            AnyView(content)
        }

        switch shape {
        case .rectangle:
            contentView
        case .circle:
            contentView.clipShape(Circle())
        case let .roundedRectangle(radius):
            contentView.clipShape(RoundedRectangle(cornerRadius: radius))
        }
    }
}

// 更新预览以展示新的形状选项
#if DEBUG
#Preview {
    VStack(spacing: 20) {
        // 圆形
        IconContainer(size: 100, shape: .circle) {
            Color.red
        }

        // 圆角矩形
        IconContainer(size: 100, shape: .roundedRectangle(radius: 20)) {
            Color.blue
        }

        // 矩形（默认）
        IconContainer(size: 100) {
            Color.green
        }

        // 在 HStack 中使用不同形状
        HStack {
            IconContainer(shape: .circle) {
                Color.yellow
            }
            IconContainer(shape: .roundedRectangle(radius: 10)) {
                Color.purple
            }
        }
        .frame(height: 50)
    }
}
#endif
