import SwiftUI

/// View扩展 - 提供Magic VStack布局的便捷方法
public extension View {
    /// 将视图包装在VStack中并居中显示
    ///
    /// 使用这个方法可以将任何SwiftUI View包装在VStack中，并自动添加Spacer来使内容垂直居中
    /// 支持自定义间距和对齐方式
    ///
    /// ```swift
    /// Text("Hello World")
    ///     .inMagicVStackCenter()
    /// ```
    ///
    /// - Parameters:
    ///   - spacing: VStack中元素之间的间距，默认为nil（使用系统默认间距）
    ///   - alignment: 水平对齐方式，默认为center
    ///   - topSpacer: 是否在顶部添加Spacer，默认为true
    ///   - bottomSpacer: 是否在底部添加Spacer，默认为true
    /// - Returns: 包装在VStack中并居中的视图
    func inMagicVStackCenter(
        spacing: CGFloat? = nil,
        alignment: HorizontalAlignment = .center,
        topSpacer: Bool = true,
        bottomSpacer: Bool = true
    ) -> some View {
        VStack(alignment: alignment, spacing: spacing) {
            if topSpacer {
                Spacer()
            }

            self

            if bottomSpacer {
                Spacer()
            }
        }
    }

    /// 将视图包装在VStack中并居中显示（简化版本）
    ///
    /// 这是`inMagicVStackCenter`的简化版本，使用默认参数
    /// 适用于大多数常见的居中布局需求
    ///
    /// ```swift
    /// Text("Hello World")
    ///     .inMagicVStackCenter()
    /// ```
    ///
    /// - Returns: 包装在VStack中并居中的视图
    func inMagicVStackCenter() -> some View {
        inMagicVStackCenter(
            spacing: nil,
            alignment: .center,
            topSpacer: true,
            bottomSpacer: true
        )
    }
}

// MARK: - Preview

#if DEBUG
    #Preview("Magic VStack Center - Default") {
        Text("Hello MagicKit!")
            .font(.title)
            .foregroundColor(.blue)
            .inMagicVStackCenter()
            .frame(width: 300, height: 600)
            .background(Color.gray.opacity(0.1))
    }

    #if DEBUG
    #Preview("Magic VStack Center - Custom Spacing") {
        VStack {
            Text("Title")
                .font(.headline)
            Text("Subtitle")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .inMagicVStackCenter(spacing: 20)
        .frame(width: 300, height: 600)
        .background(Color.gray.opacity(0.1))
    }
    #endif

    #if DEBUG
    #Preview("Magic VStack Center - Leading Alignment") {
        VStack(alignment: .leading) {
            Text("Left Aligned")
                .font(.headline)
            Text("Content")
                .font(.body)
        }
        .inMagicVStackCenter(alignment: .leading)
        .frame(width: 300, height: 200)
        .background(Color.gray.opacity(0.1))
    }
    #endif

    #if DEBUG
    #Preview("Magic VStack Center - No Spacers") {
        Text("No Spacers")
            .font(.title2)
            .inMagicVStackCenter(topSpacer: false, bottomSpacer: false)
            .frame(width: 300, height: 200)
            .background(Color.gray.opacity(0.1))
    }
    #endif
#endif
