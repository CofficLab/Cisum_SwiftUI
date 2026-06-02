import SwiftUI

// MARK: - 材质系统
extension DesignTokens {
    /// 材质令牌 - 定义背景材质和毛玻璃效果
    enum Material {
        /// 玻璃态材质 (超薄)
        static let glassUltra = SwiftUI.Material.ultraThinMaterial
        /// 玻璃态材质 (薄)
        static let glassThin = SwiftUI.Material.thinMaterial
        /// 玻璃态材质 (中等)
        static let glass = SwiftUI.Material.regularMaterial
        /// 玻璃态材质 (厚)
        static let glassThick = SwiftUI.Material.thickMaterial
        /// 玻璃态材质 (超厚)
        static let glassUltraThick = SwiftUI.Material.ultraThickMaterial

        /// 神秘氛围材质（根据配色方案调整）
        /// - Parameter scheme: 当前配色方案
        /// - Returns: 形状样式
        static func mysticGlass(for scheme: ColorScheme) -> some ShapeStyle {
            switch scheme {
            case .light:
                // 浅色模式：使用白色半透明材质
                SwiftUI.Color.white.opacity(0.6)
            case .dark:
                // 深色模式：使用黑色半透明材质
                SwiftUI.Color.black.opacity(0.3)
            @unknown default:
                SwiftUI.Color.black.opacity(0.3)
            }
        }
    }
}
