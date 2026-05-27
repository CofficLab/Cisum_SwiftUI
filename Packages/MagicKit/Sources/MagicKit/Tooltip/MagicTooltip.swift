import SwiftUI

/// Tooltip显示位置
public enum TooltipPosition {
    case top
    case bottom
    case leading
    case trailing
    case topLeading
    case topTrailing
    case bottomLeading
    case bottomTrailing
}

/// 一个功能丰富的tooltip组件，支持多种位置和样式
///
/// MagicTooltip 提供了：
/// - 支持多种显示位置
/// - 悬停时自动显示/隐藏
/// - 流畅的动画效果
/// - 自定义样式支持
/// - 自适应文本宽度
///
/// 基本用法：
/// ```swift
/// Text("Hello")
///     .withTooltip("这是一个提示")
/// ```
public struct MagicTooltip: ViewModifier {
    let text: String
    let position: TooltipPosition
    let backgroundColor: Color
    let textColor: Color
    let font: Font
    let cornerRadius: CGFloat
    let horizontalPadding: CGFloat
    let verticalPadding: CGFloat
    let offset: CGFloat
    let animationDuration: Double
    let maxWidth: CGFloat?
    let multilineTextAlignment: TextAlignment
    
    @State private var isHovered = false
    
    public init(
        text: String,
        position: TooltipPosition = .top,
        backgroundColor: Color = Color.black.opacity(0.8),
        textColor: Color = .white,
        font: Font = .caption,
        cornerRadius: CGFloat = 6,
        horizontalPadding: CGFloat = 8,
        verticalPadding: CGFloat = 4,
        offset: CGFloat = 20,
        animationDuration: Double = 0.2,
        maxWidth: CGFloat? = 200,
        multilineTextAlignment: TextAlignment = .center
    ) {
        self.text = text
        self.position = position
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.font = font
        self.cornerRadius = cornerRadius
        self.horizontalPadding = horizontalPadding
        self.verticalPadding = verticalPadding
        self.offset = offset
        self.animationDuration = animationDuration
        self.maxWidth = maxWidth
        self.multilineTextAlignment = multilineTextAlignment
    }
    
    public func body(content: Content) -> some View {
        content
            .overlay(alignment: overlayAlignment) {
                tooltipView
                    .opacity(isHovered ? 1 : 0)
                    .animation(.easeInOut(duration: animationDuration), value: isHovered)
            }
            .onHover { hovering in
                isHovered = hovering
            }
    }
    
    private var tooltipView: some View {
        Text(text)
            .font(font)
            .multilineTextAlignment(multilineTextAlignment)
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .frame(maxWidth: maxWidth)
            .background(backgroundColor)
            .foregroundColor(textColor)
            .cornerRadius(cornerRadius)
            .offset(tooltipOffset)
    }
    
    private var overlayAlignment: Alignment {
        switch position {
        case .top:
            return .top
        case .bottom:
            return .bottom
        case .leading:
            return .leading
        case .trailing:
            return .trailing
        case .topLeading:
            return .topLeading
        case .topTrailing:
            return .topTrailing
        case .bottomLeading:
            return .bottomLeading
        case .bottomTrailing:
            return .bottomTrailing
        }
    }
    
    private var tooltipOffset: CGSize {
        switch position {
        case .top:
            return CGSize(width: 0, height: -offset)
        case .bottom:
            return CGSize(width: 0, height: offset)
        case .leading:
            return CGSize(width: -offset, height: 0)
        case .trailing:
            return CGSize(width: offset, height: 0)
        case .topLeading:
            return CGSize(width: -offset/2, height: -offset)
        case .topTrailing:
            return CGSize(width: offset/2, height: -offset)
        case .bottomLeading:
            return CGSize(width: -offset/2, height: offset)
        case .bottomTrailing:
            return CGSize(width: offset/2, height: offset)
        }
    }
}

// MARK: - View Extension

public extension View {
    /// 为视图添加tooltip提示
    /// - Parameters:
    ///   - text: 提示文本
    ///   - position: 显示位置，默认为上方
    ///   - backgroundColor: 背景色，默认为半透明黑色
    ///   - textColor: 文字颜色，默认为白色
    ///   - font: 字体，默认为caption
    ///   - cornerRadius: 圆角半径，默认为6
    ///   - horizontalPadding: 水平内边距，默认为8
    ///   - verticalPadding: 垂直内边距，默认为4
    ///   - offset: 偏移距离，默认为20
    ///   - animationDuration: 动画时长，默认为0.2秒
    ///   - maxWidth: 最大宽度，默认为200，设置为nil则不限制宽度
    ///   - multilineTextAlignment: 多行文本对齐方式，默认为居中
    /// - Returns: 带有tooltip的视图
    func withTooltip(
        _ text: String,
        position: TooltipPosition = .top,
        backgroundColor: Color = Color.black.opacity(0.8),
        textColor: Color = .white,
        font: Font = .caption,
        cornerRadius: CGFloat = 6,
        horizontalPadding: CGFloat = 8,
        verticalPadding: CGFloat = 4,
        offset: CGFloat = 20,
        animationDuration: Double = 0.2,
        maxWidth: CGFloat? = 200,
        multilineTextAlignment: TextAlignment = .center
    ) -> some View {
        self.modifier(
            MagicTooltip(
                text: text,
                position: position,
                backgroundColor: backgroundColor,
                textColor: textColor,
                font: font,
                cornerRadius: cornerRadius,
                horizontalPadding: horizontalPadding,
                verticalPadding: verticalPadding,
                offset: offset,
                animationDuration: animationDuration,
                maxWidth: maxWidth,
                multilineTextAlignment: multilineTextAlignment
            )
        )
    }
    
    /// 为视图添加简单的tooltip提示（使用默认样式）
    /// - Parameter text: 提示文本
    /// - Returns: 带有tooltip的视图
    func withTooltip(_ text: String) -> some View {
        self.withTooltip(text, position: .top)
    }
    
    /// 为视图添加无宽度限制的tooltip提示
    /// - Parameters:
    ///   - text: 提示文本
    ///   - position: 显示位置，默认为上方
    /// - Returns: 带有tooltip的视图
    func withTooltipUnlimited(_ text: String, position: TooltipPosition = .top) -> some View {
        self.withTooltip(text, position: position, maxWidth: nil)
    }
    
    /// 根据条件为视图添加tooltip提示
    /// - Parameters:
    ///   - text: 提示文本（可选）
    ///   - shouldShow: 是否应该显示tooltip
    ///   - position: 显示位置，默认为上方
    ///   - backgroundColor: 背景色，默认为半透明黑色
    ///   - textColor: 文字颜色，默认为白色
    ///   - font: 字体，默认为caption
    ///   - cornerRadius: 圆角半径，默认为6
    ///   - horizontalPadding: 水平内边距，默认为8
    ///   - verticalPadding: 垂直内边距，默认为4
    ///   - offset: 偏移距离，默认为20
    ///   - animationDuration: 动画时长，默认为0.2秒
    ///   - maxWidth: 最大宽度，默认为200，设置为nil则不限制宽度
    ///   - multilineTextAlignment: 多行文本对齐方式，默认为居中
    /// - Returns: 根据条件带有或不带tooltip的视图
    @ViewBuilder
    func withConditionalTooltip(
        _ text: String?,
        shouldShow: Bool,
        position: TooltipPosition = .top,
        backgroundColor: Color = Color.black.opacity(0.8),
        textColor: Color = .white,
        font: Font = .caption,
        cornerRadius: CGFloat = 6,
        horizontalPadding: CGFloat = 8,
        verticalPadding: CGFloat = 4,
        offset: CGFloat = 20,
        animationDuration: Double = 0.2,
        maxWidth: CGFloat? = 200,
        multilineTextAlignment: TextAlignment = .center
    ) -> some View {
        if shouldShow, let tooltipText = text {
            self.withTooltip(
                tooltipText,
                position: position,
                backgroundColor: backgroundColor,
                textColor: textColor,
                font: font,
                cornerRadius: cornerRadius,
                horizontalPadding: horizontalPadding,
                verticalPadding: verticalPadding,
                offset: offset,
                animationDuration: animationDuration,
                maxWidth: maxWidth,
                multilineTextAlignment: multilineTextAlignment
            )
        } else {
            self
        }
    }
}

#if DEBUG
#Preview {
    TooltipPreviews()
        
}
#endif
