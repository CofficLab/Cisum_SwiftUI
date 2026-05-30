import SwiftUI

/// 提供创建相机图标的扩展方法
public extension Image {
    /// 创建一个可自定义的相机图标
    ///
    /// 此方法创建一个相机形状的图标，可以自定义背景、边框颜色和大小。
    /// 图标包含相机主体和闪光灯等细节，适合用于摄影或相机相关功能的UI元素。
    ///
    /// - Parameters:
    ///   - useDefaultBackground: 是否使用默认的渐变背景，默认为true
    ///   - borderColor: 相机边框的颜色，默认为蓝色
    ///   - size: 图标的大小，如果为nil则自适应父视图大小
    /// - Returns: 一个包含相机图标的视图
    ///
    /// ## 使用示例:
    /// ```swift
    /// // 创建默认相机图标
    /// Image.makeCameraIcon()
    ///
    /// // 创建自定义相机图标
    /// Image.makeCameraIcon(
    ///     useDefaultBackground: false,
    ///     borderColor: .red,
    ///     size: 100
    /// )
    /// ```
    static func makeCameraIcon(
        useDefaultBackground: Bool = true,
        borderColor: Color = .blue,
        size: CGFloat? = nil
    ) -> some View {
        IconContainer(size: size) {
            CameraIcon(
                useDefaultBackground: useDefaultBackground,
                borderColor: borderColor
            )
        }
    }
}
