import SwiftUI

public extension View {
    /// 将视图包装在材质背景的卡片中
    /// - Parameter material: 材质类型，默认为 regularMaterial
    /// - Returns: 包装在卡片中的视图
    func inCard(_ material: Material = .regularMaterial) -> some View {
        MagicCard(background: AnyView(Color.clear.background(material))) {
            self
        }
    }

    /// 将视图包装在颜色背景的卡片中
    /// - Parameter color: 背景颜色
    /// - Returns: 包装在卡片中的视图
    func inCard(color: Color) -> some View {
        MagicCard(background: color) {
            self
        }
    }

    /// 将视图包装在自定义背景的卡片中
    /// - Parameter background: 自定义背景视图
    /// - Returns: 包装在卡片中的视图
    func inCard<Background: View>(background: Background) -> some View {
        MagicCard(background: background) {
            self
        }
    }

    /// 将视图包装在渐变背景的卡片中
    /// - Parameters:
    ///   - colors: 渐变颜色数组
    ///   - startPoint: 渐变起始点
    ///   - endPoint: 渐变结束点
    /// - Returns: 包装在渐变卡片中的视图
    func inCard(
        gradient colors: [Color],
        startPoint: UnitPoint = .leading,
        endPoint: UnitPoint = .trailing
    ) -> some View {
        MagicCard(background: AnyView(LinearGradient(
            colors: colors,
            startPoint: startPoint,
            endPoint: endPoint
        ))) {
            self
        }
    }

    /// 将视图包装在毛玻璃效果的卡片中
    /// - Returns: 包装在毛玻璃卡片中的视图
    func inCardUltraThin() -> some View {
        inCard(.ultraThinMaterial)
    }

    /// 将视图包装在薄材质卡片中
    /// - Returns: 包装在薄材质卡片中的视图
    func inCardThin() -> some View {
        inCard(.thinMaterial)
    }

    /// 将视图包装在常规材质卡片中
    /// - Returns: 包装在常规材质卡片中的视图
    func inCardRegular() -> some View {
        inCard(.regularMaterial)
    }

    /// 将视图包装在厚材质卡片中
    /// - Returns: 包装在厚材质卡片中的视图
    func inCardThick() -> some View {
        inCard(.thickMaterial)
    }
}

#if DEBUG
    #Preview("Card Extensions") {
        CardPreviews()
            .frame(height: 700)
            .frame(width: 500)
    }
#endif
