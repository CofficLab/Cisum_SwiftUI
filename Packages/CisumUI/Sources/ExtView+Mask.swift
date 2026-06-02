import SwiftUI

/// View扩展 - 提供 Magic 遮罩功能
///
/// Mask 裁剪元素内容为常见形状
public extension View {
    /// 基础遮罩方法 - 使用自定义形状裁剪内容
    ///
    /// ```swift
    /// Image("photo")
    ///     .magicMask(AnyShape(Circle()))
    /// ```
    ///
    /// - Parameter shape: 遮罩形状
    /// - Returns: 裁剪后的视图
    func magicMask<S: InsettableShape>(_ shape: S) -> some View {
        self.mask(shape)
    }

    /// Squircle（超椭圆）遮罩
    ///
    /// ```swift
    /// Image("photo")
    ///     .magicMaskSquircle()
    /// ```
    func magicMaskSquircle() -> some View {
        let cornerRadius: CGFloat = 30
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        return self.mask(shape)
    }

    /// 心形遮罩
    ///
    /// ```swift
    /// Image("photo")
    ///     .magicMaskHeart()
    /// ```
    func magicMaskHeart() -> some View {
        self.mask(HeartShape())
    }

    /// 六边形遮罩（垂直）
    ///
    /// ```swift
    /// Image("photo")
    ///     .magicMaskHexagon()
    /// ```
    func magicMaskHexagon() -> some View {
        self.mask(HexagonShape())
    }

    /// 六边形遮罩（水平）
    ///
    /// ```swift
    /// Image("photo")
    ///     .magicMaskHexagon2()
    /// ```
    func magicMaskHexagon2() -> some View {
        self.mask(HexagonShape(isVertical: false))
    }

    /// 十边形遮罩
    ///
    /// ```swift
    /// Image("photo")
    ///     .magicMaskDecagon()
    /// ```
    func magicMaskDecagon() -> some View {
        self.mask(RegularPolygonShape(sides: 10))
    }

    /// 五边形遮罩
    ///
    /// ```swift
    /// Image("photo")
    ///     .magicMaskPentagon()
    /// ```
    func magicMaskPentagon() -> some View {
        self.mask(RegularPolygonShape(sides: 5))
    }

    /// 菱形遮罩
    ///
    /// ```swift
    /// Image("photo")
    ///     .magicMaskDiamond()
    /// ```
    func magicMaskDiamond() -> some View {
        self.mask(DiamondShape())
    }

    /// 正方形遮罩
    ///
    /// ```swift
    /// Image("photo")
    ///     .magicMaskSquare()
    /// ```
    func magicMaskSquare() -> some View {
        self.mask(Rectangle())
    }

    /// 圆形遮罩
    ///
    /// ```swift
    /// Image("photo")
    ///     .magicMaskCircle()
    /// ```
    func magicMaskCircle() -> some View {
        self.mask(Circle())
    }

    /// 星形遮罩
    ///
    /// ```swift
    /// Image("photo")
    ///     .magicMaskStar()
    /// ```
    func magicMaskStar() -> some View {
        self.mask(StarShape(points: 5, inset: 0.4))
    }

    /// 粗星形遮罩
    ///
    /// ```swift
    /// Image("photo")
    ///     .magicMaskStar2()
    /// ```
    func magicMaskStar2() -> some View {
        self.mask(StarShape(points: 5, inset: 0.6))
    }

    /// 三角形遮罩（指向上方）
    ///
    /// ```swift
    /// Image("photo")
    ///     .magicMaskTriangle()
    /// ```
    func magicMaskTriangle() -> some View {
        self.mask(TriangleShape(direction: .up))
    }

    /// 三角形遮罩（指向下方）
    ///
    /// ```swift
    /// Image("photo")
    ///     .magicMaskTriangle2()
    /// ```
    func magicMaskTriangle2() -> some View {
        self.mask(TriangleShape(direction: .down))
    }

    /// 三角形遮罩（指向左方）
    ///
    /// ```swift
    /// Image("photo")
    ///     .magicMaskTriangle3()
    /// ```
    func magicMaskTriangle3() -> some View {
        self.mask(TriangleShape(direction: .left))
    }

    /// 三角形遮罩（指向右方）
    ///
    /// ```swift
    /// Image("photo")
    ///     .magicMaskTriangle4()
    /// ```
    func magicMaskTriangle4() -> some View {
        self.mask(TriangleShape(direction: .right))
    }
}

// MARK: - Mask Modifiers

public extension View {
    /// 只显示前半部分（水平）
    ///
    /// ```swift
    /// Image("photo")
    ///     .magicMaskHalf1()
    /// ```
    func magicMaskHalf1() -> some View {
        self.mask(
            GeometryReader { geometry in
                Rectangle()
                    .frame(width: geometry.size.width / 2)
            }
        )
    }

    /// 只显示后半部分（水平）
    ///
    /// ```swift
    /// Image("photo")
    ///     .magicMaskHalf2()
    /// ```
    func magicMaskHalf2() -> some View {
        self.mask(
            GeometryReader { geometry in
                Rectangle()
                    .frame(width: geometry.size.width / 2)
                    .offset(x: geometry.size.width / 2)
            }
        )
    }
}

#if DEBUG
    #Preview("Mask") {
        MaskPreviews()
            .frame(height: 800)
            .frame(width: 600)
    }
#endif
