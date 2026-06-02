import SwiftUI

// MARK: - Style Configuration
/// 复制视图的形状样式
public enum CopyViewShape {
    /// 圆角矩形（默认）
    case roundedRectangle
    /// 矩形
    case rectangle
    /// 胶囊形状
    case capsule
}

/// 复制视图的样式配置
struct CopyViewStyle {
    /// 背景颜色
    var background: Color = .white
    /// 背景不透明度
    var backgroundOpacity: Double = 0.8
    /// 形状样式
    var shape: CopyViewShape = .roundedRectangle
    /// 圆角半径（仅用于圆角矩形）
    var cornerRadius: CGFloat = 12
    /// 阴影半径
    var shadowRadius: CGFloat = 2
    /// 是否自动开始复制
    var autoStart: Bool = true
}

// MARK: - Environment
struct CopyViewStyleKey: EnvironmentKey {
    static let defaultValue = CopyViewStyle()
}

extension EnvironmentValues {
    var copyViewStyle: CopyViewStyle {
        get { self[CopyViewStyleKey.self] }
        set { self[CopyViewStyleKey.self] = newValue }
    }
}

// MARK: - Style Modifiers
extension View {
    /// 设置复制视图的背景色
    /// - Parameters:
    ///   - color: 背景颜色
    ///   - opacity: 不透明度
    /// - Returns: 修改后的视图
    public func withBackground(_ color: Color = .white, opacity: Double = 0.8) -> some View {
        transformEnvironment(\.copyViewStyle) { style in
            style.background = color
            style.backgroundOpacity = opacity
        }
    }
    
    /// 设置复制视图的形状
    /// - Parameters:
    ///   - shape: 形状样式
    ///   - cornerRadius: 圆角半径（仅用于圆角矩形）
    /// - Returns: 修改后的视图
    public func withShape(_ shape: CopyViewShape, cornerRadius: CGFloat = 12) -> some View {
        transformEnvironment(\.copyViewStyle) { style in
            style.shape = shape
            style.cornerRadius = cornerRadius
        }
    }
    
    /// 设置复制视图的阴影
    /// - Parameter radius: 阴影半径
    /// - Returns: 修改后的视图
    public func withShadow(radius: CGFloat = 2) -> some View {
        transformEnvironment(\.copyViewStyle) { style in
            style.shadowRadius = radius
        }
    }
    
    /// 设置复制视图是否自动开始复制
    /// - Parameter autoStart: 是否自动开始复制
    /// - Returns: 修改后的视图
    public func withAutoStart(_ autoStart: Bool) -> some View {
        transformEnvironment(\.copyViewStyle) { style in
            style.autoStart = autoStart
        }
    }
}

// MARK: - Shape Modifier
/// 形状修改器
struct ShapeModifier: ViewModifier {
    let style: CopyViewStyle
    
    func body(content: Content) -> some View {
        switch style.shape {
        case .roundedRectangle:
            content.clipShape(RoundedRectangle(cornerRadius: style.cornerRadius))
        case .rectangle:
            content.clipShape(Rectangle())
        case .capsule:
            content.clipShape(Capsule())
        }
    }
}

#if DEBUG
#Preview("Copy View") {
    CopyViewPreviewContainer()
}
#endif
