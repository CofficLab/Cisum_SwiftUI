import SwiftUI

/// View扩展 - 提供Magic阴影配置的便捷方法
public extension View {
    /// 为视图添加阴影效果（自定义）
    ///
    /// 使用这个方法可以轻松为任何视图添加阴影效果
    /// 支持自定义阴影半径、偏移和颜色
    ///
    /// ```swift
    /// Text("Hello World")
    ///     .sShadow(radius: 5)
    /// ```
    ///
    /// - Parameters:
    ///   - color: 阴影颜色，默认为黑色
    ///   - radius: 阴影半径，默认为8
    ///   - x: X轴偏移量，默认为0
    ///   - y: Y轴偏移量，默认为2
    /// - Returns: 带有阴影效果的视图
    func sShadow(
        color: Color = .black.opacity(0.1),
        radius: CGFloat = 8,
        x: CGFloat = 0,
        y: CGFloat = 2
    ) -> some View {
        ApplyShadowView(content: self, color: color, radius: radius, x: x, y: y)
    }

    /// 为视图添加超小阴影效果 (shadow-xs)
    ///
    /// 使用预设的超小阴影配置
    /// - Radius: 1
    /// - Y: 1
    /// - Opacity: 0.05
    ///
    /// ```swift
    /// Text("Extra Small Shadow")
    ///     .shadowXs()
    /// ```
    ///
    /// - Returns: 带有超小阴影效果的视图
    func shadowXs() -> some View {
        self.sShadow(
            color: .black.opacity(0.05),
            radius: 1,
            x: 0,
            y: 1
        )
    }

    /// 为视图添加小阴影效果 (shadow-sm)
    ///
    /// 使用预设的小阴影配置
    /// - Radius: 2
    /// - Y: 1
    /// - Opacity: 0.1
    ///
    /// ```swift
    /// Text("Small Shadow")
    ///     .shadowSm()
    /// ```
    ///
    /// - Returns: 带有小阴影效果的视图
    func shadowSm() -> some View {
        self.sShadow(
            color: .black.opacity(0.1),
            radius: 2,
            x: 0,
            y: 1
        )
    }

    /// 为视图添加默认阴影效果 (shadow)
    ///
    /// 使用预设的默认阴影配置
    /// - Radius: 4
    /// - Y: 1
    /// - Opacity: 0.1
    ///
    /// ```swift
    /// Text("Default Shadow")
    ///     .shadowMd()
    /// ```
    ///
    /// - Returns: 带有默认阴影效果的视图
    func shadowMd() -> some View {
        self.sShadow(
            color: .black.opacity(0.1),
            radius: 4,
            x: 0,
            y: 1
        )
    }

    /// 为视图添加中等阴影效果 (shadow-md)
    ///
    /// 使用预设的中等阴影配置
    /// - Radius: 6
    /// - Y: 4
    /// - Opacity: 0.1
    ///
    /// ```swift
    /// Text("Medium Shadow")
    ///     .shadowLg()
    /// ```
    ///
    /// - Returns: 带有中等阴影效果的视图
    func shadowLg() -> some View {
        self.sShadow(
            color: .black.opacity(0.1),
            radius: 6,
            x: 0,
            y: 4
        )
    }

    /// 为视图添加大阴影效果 (shadow-lg)
    ///
    /// 使用预设的大阴影配置
    /// - Radius: 10
    /// - Y: 6
    /// - Opacity: 0.15
    ///
    /// ```swift
    /// Text("Large Shadow")
    ///     .shadowXl()
    /// ```
    ///
    /// - Returns: 带有大阴影效果的视图
    func shadowXl() -> some View {
        self.sShadow(
            color: .black.opacity(0.15),
            radius: 10,
            x: 0,
            y: 6
        )
    }

    /// 为视图添加超大阴影效果 (shadow-xl)
    ///
    /// 使用预设的超大阴影配置
    /// - Radius: 20
    /// - Y: 12
    /// - Opacity: 0.15
    ///
    /// ```swift
    /// Text("Extra Large Shadow")
    ///     .shadow2xl()
    /// ```
    ///
    /// - Returns: 带有超大阴影效果的视图
    func shadow2xl() -> some View {
        self.sShadow(
            color: .black.opacity(0.15),
            radius: 20,
            x: 0,
            y: 12
        )
    }

    /// 为视图添加特大阴影效果 (shadow-2xl)
    ///
    /// 使用预设的特大阴影配置
    /// - Radius: 25
    /// - Y: 20
    /// - Opacity: 0.25
    ///
    /// ```swift
    /// Text("Extra Extra Large Shadow")
    ///     .shadow3xl()
    /// ```
    ///
    /// - Returns: 带有特大阴影效果的视图
    func shadow3xl() -> some View {
        self.sShadow(
            color: .black.opacity(0.25),
            radius: 25,
            x: 0,
            y: 20
        )
    }

    /// 为视图添加内阴影效果 (shadow-inner)
    ///
    /// 使用内阴影效果，模拟凹陷效果
    ///
    /// ```swift
    /// Text("Inner Shadow")
    ///     .shadowInner()
    /// ```
    ///
    /// - Returns: 带有内阴影效果的视图
    func shadowInner() -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: 0)
                .stroke(Color.black.opacity(0.1), lineWidth: 2)
                .blur(radius: 4)
                .offset(x: 0, y: 2)
                .mask(
                    RoundedRectangle(cornerRadius: 0)
                )
        )
    }

    /// 为视图添加彩色阴影效果
    ///
    /// 支持自定义颜色的阴影效果
    ///
    /// ```swift
    /// Text("Colored Shadow")
    ///     .shadowColor(.blue, radius: 8)
    /// ```
    ///
    /// - Parameters:
    ///   - color: 阴影颜色
    ///   - radius: 阴影半径，默认为8
    ///   - x: X轴偏移量，默认为0
    ///   - y: Y轴偏移量，默认为2
    /// - Returns: 带有彩色阴影效果的视图
    func shadowColor(
        _ color: Color,
        radius: CGFloat = 8,
        x: CGFloat = 0,
        y: CGFloat = 2
    ) -> some View {
        self.sShadow(color: color, radius: radius, x: x, y: y)
    }

    /// 为视图添加卡片样式阴影效果
    ///
    /// 使用卡片样式的阴影配置（中等阴影）
    ///
    /// ```swift
    /// VStack { ... }
    ///     .shadowCard()
    /// ```
    ///
    /// - Returns: 带有卡片样式阴影效果的视图
    func shadowCard() -> some View {
        self.sShadow(
            color: .black.opacity(0.08),
            radius: 12,
            x: 0,
            y: 4
        )
    }

    /// 为视图添加按钮样式阴影效果
    ///
    /// 使用按钮样式的阴影配置（小阴影）
    ///
    /// ```swift
    /// Button("Click Me") { }
    ///     .shadowButton()
    /// ```
    ///
    /// - Returns: 带有按钮样式阴影效果的视图
    func shadowButton() -> some View {
        self.sShadow(
            color: .black.opacity(0.1),
            radius: 3,
            x: 0,
            y: 2
        )
    }

    /// 移除视图的阴影效果
    ///
    /// ```swift
    /// Text("No Shadow")
    ///     .shadowNone()
    /// ```
    ///
    /// - Returns: 无阴影效果的视图
    func shadowNone() -> some View {
        self.sShadow(color: .clear, radius: 0, x: 0, y: 0)
    }
}

// MARK: - Helper Views

/// 应用阴影的辅助视图
private struct ApplyShadowView<Content: View>: View {
    let content: Content
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat

    init(content: Content, color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) {
        self.content = content
        self.color = color
        self.radius = radius
        self.x = x
        self.y = y
    }

    var body: some View {
        content.shadow(color: color, radius: radius, x: x, y: y)
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    MagicShadowPreviews()
}
#endif
