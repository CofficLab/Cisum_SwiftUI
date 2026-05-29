/// 包含 SwiftUI Image 相关的书本图标扩展和实现的文件。
/// 该文件提供了创建可自定义样式和形状的书本图标的功能。
import SwiftUI

public extension Image {
    /// 使用指定参数创建可自定义的书本图标视图。
    ///
    /// 此方法提供了一种便捷的方式来创建具有可自定义外观的书本图标，
    /// 包括背景、边框颜色、大小和形状选项。
    ///
    /// - Parameters:
    ///   - useDefaultBackground: 布尔值，决定是否使用默认渐变背景。
    ///                          当为 true 时，应用紫色到蓝色的渐变。默认为 true。
    ///   - borderColor: 图标边框的颜色。默认为蓝色。
    ///   - size: 图标的可选显式大小。如果为 nil，则适应容器大小。
    ///   - shape: 图标容器的形状。默认为圆形。
    ///
    /// - Returns: 包含配置好的书本图标的视图。
    static func makeBookIcon(
        useDefaultBackground: Bool = true,
        borderColor: Color = .blue,
        size: CGFloat? = nil,
        shape: IconShape = .circle
    ) -> some View {
        IconContainer(size: size, shape: shape) {
            BookIcon(
                useDefaultBackground: useDefaultBackground,
                borderColor: borderColor
            )
        }
    }
}

/// 渲染具有可自定义外观的风格化书本图标的视图。
///
/// 该视图负责书本图标的实际渲染，包括
/// 背景、边框和具有适当样式的书本符号本身。
struct BookIcon: View {
    /// 确定是否使用默认渐变背景。
    let useDefaultBackground: Bool
    
    /// 用于图标边框的颜色。
    let borderColor: Color

    /// 书本图标视图的主体。
    var body: some View {
        // 使用 GeometryReader 使图标响应其容器大小
        GeometryReader { geometry in
            // 计算基本大小为宽度和高度的最小值，以保持纵横比
            let size = min(geometry.size.width, geometry.size.height)
            
            // 堆叠书本图标的所有元素（背景、边框和符号）
            ZStack {
                // 背景层：紫色到蓝色的渐变，营造知识的神秘感
                if useDefaultBackground {
                    LinearGradient(
                        colors: [.purple.opacity(0.6), .blue.opacity(0.4)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                } else {
                    Color.clear
                }

                // 边框层：圆角矩形边框，提供图标的基本轮廓
                RoundedRectangle(cornerRadius: size * 0.2)
                    .stroke(borderColor, lineWidth: size * 0.08)
                    .frame(width: size * 0.9, height: size * 0.9)

                // 图标层：书本图标带有渐变色填充
                Image(systemName: "book.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size * 0.5) // 控制书本图标大小为容器的一半
                    .foregroundStyle(
                        // 橙色到紫色的渐变，模拟书本的光泽和质感
                        .linearGradient(
                            colors: [.orange, .red, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    // 添加阴影增加立体感
                    .shadow(color: .black.opacity(0.2), radius: 3, x: 2, y: 2)
            }
        }
    }
}

/// 提供不同书本图标配置的预览。
///
/// 此预览展示了书本图标的各种样式和形状：
/// - 默认配置
/// - 圆形形状
/// - 矩形形状
/// - 自定义圆角矩形形状
#if DEBUG
#Preview {
    // 预览项目之间具有一致间距的垂直堆栈
    VStack(spacing: 20) {
        IconPreviewHelper(title: "书本图标（默认）") {
            Image.makeBookIcon()
        }
        
        IconPreviewHelper(title: "书本图标（圆形）") {
            Image.makeBookIcon(shape: .circle)
        }
        
        IconPreviewHelper(title: "书本图标（矩形）") {
            Image.makeBookIcon(shape: .rectangle)
        }
        
        IconPreviewHelper(title: "书本图标（自定义圆角）") {
            Image.makeBookIcon(shape: .roundedRectangle(radius: 24))
        }
    }
}
#endif
