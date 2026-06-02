import SwiftUI

public extension View {
    /// 为预览视图添加通用容器（使用CGSize指定尺寸）
    /// - Parameters:
    ///   - containerSize: 容器尺寸，默认为 500x750
    ///   - scale: 缩放比例，默认为 1.0
    /// - Returns: MagicContainer 视图
    func inMagicContainer(_ containerSize: CGSize = CGSize(width: 500, height: 750), scale: CGFloat = 1.0) -> some View {
        MagicContainer(containerSize, scale: scale) {
            self
        }
    }

    /// 为预览视图添加缩放功能
    /// - Parameter scale: 缩放比例，默认为 1.0
    /// - Returns: 带有缩放功能的视图
    func magicScale(_ scale: CGFloat = 1.0) -> some View {
        self.scaleEffect(scale)
    }
}
