import SwiftUI

/// View扩展 - 提供类似Tailwind CSS的Padding快捷方法
public extension View {
    // MARK: - All Sides (p-)

    /// 为视图添加零内边距 (p-0)
    ///
    /// ```swift
    /// Text("No Padding")
    ///     .p0()
    /// ```
    ///
    /// - Returns: 视图
    func p0() -> some View {
        self.padding(0)
    }

    /// 为视图添加超小内边距 (p-1: 4pt)
    ///
    /// ```swift
    /// Text("Extra Small")
    ///     .p1()
    /// ```
    ///
    /// - Returns: 视图
    func p1() -> some View {
        self.padding(4)
    }

    /// 为视图添加小内边距 (p-2: 8pt)
    ///
    /// ```swift
    /// Text("Small")
    ///     .p2()
    /// ```
    ///
    /// - Returns: 视图
    func p2() -> some View {
        self.padding(8)
    }

    /// 为视图添加默认内边距 (p-3: 12pt)
    ///
    /// ```swift
    /// Text("Default")
    ///     .p3()
    /// ```
    ///
    /// - Returns: 视图
    func p3() -> some View {
        self.padding(12)
    }

    /// 为视图添加中等内边距 (p-4: 16pt)
    ///
    /// ```swift
    /// Text("Medium")
    ///     .p4()
    /// ```
    ///
    /// - Returns: 视图
    func p4() -> some View {
        self.padding(16)
    }

    /// 为视图添加大内边距 (p-5: 20pt)
    ///
    /// ```swift
    /// Text("Large")
    ///     .p5()
    /// ```
    ///
    /// - Returns: 视图
    func p5() -> some View {
        self.padding(20)
    }

    /// 为视图添加超大内边距 (p-6: 24pt)
    ///
    /// ```swift
    /// Text("Extra Large")
    ///     .p6()
    /// ```
    ///
    /// - Returns: 视图
    func p6() -> some View {
        self.padding(24)
    }

    /// 为视图添加特大内边距 (p-8: 32pt)
    ///
    /// ```swift
    /// Text("Extra Extra Large")
    ///     .p8()
    /// ```
    ///
    /// - Returns: 视图
    func p8() -> some View {
        self.padding(32)
    }

    // MARK: - Horizontal (px-)

    /// 为视图添加水平方向零内边距 (px-0)
    ///
    /// ```swift
    /// Text("No Horizontal Padding")
    ///     .px0()
    /// ```
    ///
    /// - Returns: 视图
    func px0() -> some View {
        self.padding(.horizontal, 0)
    }

    /// 为视图添加水平方向超小内边距 (px-1: 4pt)
    ///
    /// ```swift
    /// Text("Small Horizontal")
    ///     .px1()
    /// ```
    ///
    /// - Returns: 视图
    func px1() -> some View {
        self.padding(.horizontal, 4)
    }

    /// 为视图添加水平方向小内边距 (px-2: 8pt)
    ///
    /// ```swift
    /// Text("Small Horizontal")
    ///     .px2()
    /// ```
    ///
    /// - Returns: 视图
    func px2() -> some View {
        self.padding(.horizontal, 8)
    }

    /// 为视图添加水平方向默认内边距 (px-3: 12pt)
    ///
    /// ```swift
    /// Text("Default Horizontal")
    ///     .px3()
    /// ```
    ///
    /// - Returns: 视图
    func px3() -> some View {
        self.padding(.horizontal, 12)
    }

    /// 为视图添加水平方向中等内边距 (px-4: 16pt)
    ///
    /// ```swift
    /// Text("Medium Horizontal")
    ///     .px4()
    /// ```
    ///
    /// - Returns: 视图
    func px4() -> some View {
        self.padding(.horizontal, 16)
    }

    /// 为视图添加水平方向大内边距 (px-6: 24pt)
    ///
    /// ```swift
    /// Text("Large Horizontal")
    ///     .px6()
    /// ```
    ///
    /// - Returns: 视图
    func px6() -> some View {
        self.padding(.horizontal, 24)
    }

    /// 为视图添加水平方向超大内边距 (px-8: 32pt)
    ///
    /// ```swift
    /// Text("Extra Large Horizontal")
    ///     .px8()
    /// ```
    ///
    /// - Returns: 视图
    func px8() -> some View {
        self.padding(.horizontal, 32)
    }

    // MARK: - Vertical (py-)

    /// 为视图添加垂直方向零内边距 (py-0)
    ///
    /// ```swift
    /// Text("No Vertical Padding")
    ///     .py0()
    /// ```
    ///
    /// - Returns: 视图
    func py0() -> some View {
        self.padding(.vertical, 0)
    }

    /// 为视图添加垂直方向超小内边距 (py-1: 4pt)
    ///
    /// ```swift
    /// Text("Small Vertical")
    ///     .py1()
    /// ```
    ///
    /// - Returns: 视图
    func py1() -> some View {
        self.padding(.vertical, 4)
    }

    /// 为视图添加垂直方向小内边距 (py-2: 8pt)
    ///
    /// ```swift
    /// Text("Small Vertical")
    ///     .py2()
    /// ```
    ///
    /// - Returns: 视图
    func py2() -> some View {
        self.padding(.vertical, 8)
    }

    /// 为视图添加垂直方向默认内边距 (py-3: 12pt)
    ///
    /// ```swift
    /// Text("Default Vertical")
    ///     .py3()
    /// ```
    ///
    /// - Returns: 视图
    func py3() -> some View {
        self.padding(.vertical, 12)
    }

    /// 为视图添加垂直方向中等内边距 (py-4: 16pt)
    ///
    /// ```swift
    /// Text("Medium Vertical")
    ///     .py4()
    /// ```
    ///
    /// - Returns: 视图
    func py4() -> some View {
        self.padding(.vertical, 16)
    }

    /// 为视图添加垂直方向大内边距 (py-6: 24pt)
    ///
    /// ```swift
    /// Text("Large Vertical")
    ///     .py6()
    /// ```
    ///
    /// - Returns: 视图
    func py6() -> some View {
        self.padding(.vertical, 24)
    }

    /// 为视图添加垂直方向超大内边距 (py-8: 32pt)
    ///
    /// ```swift
    /// Text("Extra Large Vertical")
    ///     .py8()
    /// ```
    ///
    /// - Returns: 视图
    func py8() -> some View {
        self.padding(.vertical, 32)
    }

    // MARK: - Top (pt-)

    /// 为视图添加顶部零内边距 (pt-0)
    func pt0() -> some View {
        self.padding(.top, 0)
    }

    /// 为视图添加顶部超小内边距 (pt-1: 4pt)
    func pt1() -> some View {
        self.padding(.top, 4)
    }

    /// 为视图添加顶部小内边距 (pt-2: 8pt)
    func pt2() -> some View {
        self.padding(.top, 8)
    }

    /// 为视图添加顶部默认内边距 (pt-3: 12pt)
    func pt3() -> some View {
        self.padding(.top, 12)
    }

    /// 为视图添加顶部中等内边距 (pt-4: 16pt)
    func pt4() -> some View {
        self.padding(.top, 16)
    }

    /// 为视图添加顶部大内边距 (pt-6: 24pt)
    func pt6() -> some View {
        self.padding(.top, 24)
    }

    /// 为视图添加顶部超大内边距 (pt-8: 32pt)
    func pt8() -> some View {
        self.padding(.top, 32)
    }

    // MARK: - Bottom (pb-)

    /// 为视图添加底部零内边距 (pb-0)
    func pb0() -> some View {
        self.padding(.bottom, 0)
    }

    /// 为视图添加底部超小内边距 (pb-1: 4pt)
    func pb1() -> some View {
        self.padding(.bottom, 4)
    }

    /// 为视图添加底部小内边距 (pb-2: 8pt)
    func pb2() -> some View {
        self.padding(.bottom, 8)
    }

    /// 为视图添加底部默认内边距 (pb-3: 12pt)
    func pb3() -> some View {
        self.padding(.bottom, 12)
    }

    /// 为视图添加底部中等内边距 (pb-4: 16pt)
    func pb4() -> some View {
        self.padding(.bottom, 16)
    }

    /// 为视图添加底部大内边距 (pb-6: 24pt)
    func pb6() -> some View {
        self.padding(.bottom, 24)
    }

    /// 为视图添加底部超大内边距 (pb-8: 32pt)
    func pb8() -> some View {
        self.padding(.bottom, 32)
    }

    // MARK: - Leading (pl-)

    /// 为视图添加前导零内边距 (pl-0)
    func pl0() -> some View {
        self.padding(.leading, 0)
    }

    /// 为视图添加前导超小内边距 (pl-1: 4pt)
    func pl1() -> some View {
        self.padding(.leading, 4)
    }

    /// 为视图添加前导小内边距 (pl-2: 8pt)
    func pl2() -> some View {
        self.padding(.leading, 8)
    }

    /// 为视图添加前导默认内边距 (pl-3: 12pt)
    func pl3() -> some View {
        self.padding(.leading, 12)
    }

    /// 为视图添加前导中等内边距 (pl-4: 16pt)
    func pl4() -> some View {
        self.padding(.leading, 16)
    }

    /// 为视图添加前导大内边距 (pl-6: 24pt)
    func pl6() -> some View {
        self.padding(.leading, 24)
    }

    /// 为视图添加前导超大内边距 (pl-8: 32pt)
    func pl8() -> some View {
        self.padding(.leading, 32)
    }

    // MARK: - Trailing (pr-)

    /// 为视图添加尾随零内边距 (pr-0)
    func pr0() -> some View {
        self.padding(.trailing, 0)
    }

    /// 为视图添加尾随超小内边距 (pr-1: 4pt)
    func pr1() -> some View {
        self.padding(.trailing, 4)
    }

    /// 为视图添加尾随小内边距 (pr-2: 8pt)
    func pr2() -> some View {
        self.padding(.trailing, 8)
    }

    /// 为视图添加尾随默认内边距 (pr-3: 12pt)
    func pr3() -> some View {
        self.padding(.trailing, 12)
    }

    /// 为视图添加尾随中等内边距 (pr-4: 16pt)
    func pr4() -> some View {
        self.padding(.trailing, 16)
    }

    /// 为视图添加尾随大内边距 (pr-6: 24pt)
    func pr6() -> some View {
        self.padding(.trailing, 24)
    }

    /// 为视图添加尾随超大内边距 (pr-8: 32pt)
    func pr8() -> some View {
        self.padding(.trailing, 32)
    }

    // MARK: - Combinations

    /// 为视图添加紧凑垂直和宽松水平内边距
    ///
    /// 垂直: 8pt, 水平: 16pt
    ///
    /// ```swift
    /// Text("Compact Vertical")
    ///     .py2Px4()
    /// ```
    ///
    /// - Returns: 视图
    func py2px4() -> some View {
        self.padding(.vertical, 8)
            .padding(.horizontal, 16)
    }

    /// 为视图添加默认垂直和宽松水平内边距
    ///
    /// 垂直: 12pt, 水平: 20pt
    ///
    /// ```swift
    /// Text("Default")
    ///     .py3Px5()
    /// ```
    ///
    /// - Returns: 视图
    func py3px5() -> some View {
        self.padding(.vertical, 12)
            .padding(.horizontal, 20)
    }

    /// 为视图添加中等垂直和宽松水平内边距
    ///
    /// 垂直: 16pt, 水平: 24pt
    ///
    /// ```swift
    /// Text("Medium")
    ///     .py4px6()
    /// ```
    ///
    /// - Returns: 视图
    func py4px6() -> some View {
        self.padding(.vertical, 16)
            .padding(.horizontal, 24)
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    MagicPaddingPreviews()
        .frame(height: 600)
        .frame(width: 500)
}
#endif
