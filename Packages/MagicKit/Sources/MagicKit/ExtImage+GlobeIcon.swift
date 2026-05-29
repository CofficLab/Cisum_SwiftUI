import SwiftUI

/// Image 扩展，提供创建地球图标的功能
public extension Image {
    /// 创建一个自定义的地球图标
    ///
    /// 此方法创建一个可自定义的地球图标，可用于应用中表示全球化、互联网或地理位置等概念。
    ///
    /// - Parameters:
    ///   - useDefaultBackground: 是否使用默认的太空背景，默认为 true
    ///   - borderColor: 图标边框的颜色，默认为蓝色
    ///   - size: 图标的大小，如果为 nil 则使用容器默认大小
    /// - Returns: 一个可以在 SwiftUI 视图中使用的地球图标视图
    ///
    /// ## 使用示例:
    /// ```swift
    /// // 创建默认地球图标
    /// Image.makeGlobeIcon()
    ///
    /// // 创建自定义地球图标
    /// Image.makeGlobeIcon(
    ///     useDefaultBackground: false,
    ///     borderColor: .green,
    ///     size: 100
    /// )
    /// ```
    static func makeGlobeIcon(
        useDefaultBackground: Bool = true,
        borderColor: Color = .blue,
        size: CGFloat? = nil
    ) -> some View {
        IconContainer(size: size) {
            GlobeIcon(
                useDefaultBackground: useDefaultBackground,
                borderColor: borderColor
            )
        }
    }
}
