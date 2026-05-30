import SwiftUI

/// Image 扩展，提供创建儿童教育图标的功能
public extension Image {
    /// 创建一个自定义的儿童教育图标
    ///
    /// 此方法创建一个可自定义的儿童教育图标，可用于应用中表示儿童教育、学习内容或儿童友好的功能。
    /// 图标采用明亮的色彩和活泼的设计，适合儿童教育类应用。
    ///
    /// - Parameters:
    ///   - useDefaultBackground: 是否使用默认的彩虹渐变背景，默认为 true
    ///   - borderColor: 图标边框的颜色，默认为蓝色
    ///   - size: 图标的大小，如果为 nil 则使用容器默认大小
    /// - Returns: 一个可以在 SwiftUI 视图中使用的儿童教育图标视图
    ///
    /// ## 使用示例:
    /// ```swift
    /// // 创建默认儿童教育图标
    /// Image.makeKidsEduIcon()
    ///
    /// // 创建自定义儿童教育图标
    /// Image.makeKidsEduIcon(
    ///     useDefaultBackground: false,
    ///     borderColor: .purple,
    ///     size: 120
    /// )
    /// ```
    static func makeKidsEduIcon(
        useDefaultBackground: Bool = true,
        borderColor: Color = .blue,
        size: CGFloat? = nil
    ) -> some View {
        IconContainer(size: size) {
            KidsEduIcon(
                useDefaultBackground: useDefaultBackground,
                borderColor: borderColor
            )
        }
    }
}
