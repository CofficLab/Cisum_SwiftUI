import SwiftUI

/// View扩展 - 悬停效果相关
public extension View {
    /// 为视图添加悬停缩放效果
    ///
    /// 当鼠标悬停在视图上时，视图会缩放到指定比例
    ///
    /// ```swift
    /// Text("Hover me")
    ///     .hoverScale(110)
    ///
    /// Image(systemName: "star")
    ///     .hoverScale(125)
    /// ```
    ///
    /// - Parameter scale: 缩放百分比，例如 110 表示 110%（1.1倍）
    /// - Returns: 带悬停缩放效果的视图
    func hoverScale(_ scale: CGFloat) -> some View {
        self.modifier(HoverScaleModifier(scale: scale / 100.0))
    }

    /// 为视图添加悬停缩放效果和动画
    ///
    /// 当鼠标悬停在视图上时，视图会以指定动画缩放到指定比例
    ///
    /// ```swift
    /// Text("Hover me")
    ///     .hoverScale(110, duration: 0.3)
    /// ```
    ///
    /// - Parameters:
    ///   - scale: 缩放百分比，例如 110 表示 110%（1.1倍）
    ///   - duration: 动画持续时间（秒）
    /// - Returns: 带悬停缩放效果的视图
    func hoverScale(_ scale: CGFloat, duration: Double) -> some View {
        self.modifier(HoverScaleModifier(scale: scale / 100.0, duration: duration))
    }

    /// 为视图添加悬停时显示的背景
    ///
    /// 当鼠标悬停在视图上时显示背景，移开时隐藏背景
    ///
    /// ```swift
    /// Text("Hover me")
    ///     .padding()
    ///     .hoverBackground(.blue.opacity(0.1))
    ///
    /// Image(systemName: "star")
    ///     .padding(10)
    ///     .hoverBackground(.quaternary, cornerRadius: 8)
    /// ```
    ///
    /// - Parameter background: 背景样式，可以是 Color、Material 等
    /// - Returns: 带悬停背景效果的视图
    func hoverBackground<S: ShapeStyle>(_ background: S) -> some View {
        self.modifier(HoverBackgroundModifier(background: background))
    }

    /// 为视图添加悬停时显示的背景（自定义圆角和动画）
    ///
    /// 当鼠标悬停在视图上时显示背景，移开时隐藏背景
    ///
    /// ```swift
    /// Text("Hover me")
    ///     .padding()
    ///     .hoverBackground(.blue.opacity(0.1), cornerRadius: 12, duration: 0.3)
    /// ```
    ///
    /// - Parameters:
    ///   - background: 背景样式，可以是 Color、Material 等
    ///   - cornerRadius: 圆角半径，默认 8
    ///   - duration: 动画持续时间（秒），默认 0.2
    /// - Returns: 带悬停背景效果的视图
    func hoverBackground<S: ShapeStyle>(_ background: S, cornerRadius: CGFloat, duration: Double) -> some View {
        self.modifier(HoverBackgroundModifier(background: background, cornerRadius: cornerRadius, duration: duration))
    }
}

#if DEBUG
    #Preview("Hover Extensions") {
        HoverExtensionPreview()
            .frame(height: 700)
            .frame(width: 500)
    }
#endif
