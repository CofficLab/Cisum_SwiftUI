import SwiftUI

/// 魔法卡片组件，支持自定义背景和内容
/// 提供统一的卡片样式，包含圆角、padding 和背景
struct MagicCard<Content, Background>: View where Content: View, Background: View {
    /// 卡片内容
    private let content: Content
    /// 卡片背景
    private var background: Background
    /// 垂直内边距
    private var paddingVertical: CGFloat = 8

    /// 初始化方法
    /// - Parameters:
    ///   - background: 卡片背景视图
    ///   - paddingVertical: 垂直内边距，默认值为 8
    ///   - content: 卡片内容视图构建器
    public init(background: Background, paddingVertical: CGFloat? = nil, @ViewBuilder content: () -> Content) {
        self.background = background
        self.content = content()
        self.paddingVertical = paddingVertical ?? self.paddingVertical
    }

    /// 视图主体
    /// 应用水平和垂直内边距，设置背景，并裁剪为圆角矩形
    public var body: some View {
        content
            .padding(.horizontal, 16)
            .padding(.vertical, paddingVertical)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
