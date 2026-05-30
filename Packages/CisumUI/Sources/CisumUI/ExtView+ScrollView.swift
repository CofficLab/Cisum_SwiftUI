import SwiftUI

/// View扩展 - 提供Magic ScrollView布局的便捷方法
public extension View {
    /// 将视图包装在ScrollView中
    ///
    /// 使用这个方法可以将任何SwiftUI View包装在ScrollView中，支持水平和垂直滚动
    /// 支持自定义滚动方向、显示滚动指示器等
    ///
    /// ```swift
    /// VStack {
    ///     Text("Content 1")
    ///     Text("Content 2")
    ///     // ... more content
    /// }
    ///     .inScrollView()
    /// ```
    ///
    /// - Parameters:
    ///   - axes: 滚动方向，默认为.vertical
    ///   - showsIndicators: 是否显示滚动指示器，默认为true
    ///   - contentInsets: 内容的内边距，默认为nil（无内边距）
    /// - Returns: 包装在ScrollView中的视图
    func inScrollView(
        axes: Axis.Set = .vertical,
        showsIndicators: Bool = true,
        contentInsets: EdgeInsets? = nil
    ) -> some View {
        ScrollView(axes, showsIndicators: showsIndicators) {
            if let insets = contentInsets {
                self.padding(insets)
            } else {
                self
            }
        }
    }

    /// 将视图包装在垂直ScrollView中（简化版本）
    ///
    /// 这是`inScrollView`的简化版本，专门用于垂直滚动
    /// 使用默认参数，适用于大多数常见的垂直滚动需求
    ///
    /// ```swift
    /// VStack {
    ///     ForEach(items) { item in
    ///         Text(item.title)
    ///     }
    /// }
    ///     .inScrollView()
    /// ```
    ///
    /// - Returns: 包装在垂直ScrollView中的视图
    func inScrollView() -> some View {
        inScrollView(
            axes: .vertical,
            showsIndicators: true,
            contentInsets: nil
        )
    }
}

// MARK: - Preview

#if DEBUG
    #Preview("Magic ScrollView - Vertical") {
        VStack(spacing: 20) {
            ForEach(1..<21) { index in
                Text("Item \(index)")
                    .font(.title2)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .inScrollView()
        .frame(width: 400, height: 500)
        .background(Color.gray.opacity(0.1))
    }

    #if DEBUG
    #Preview("Magic ScrollView - Horizontal") {
        HStack(spacing: 20) {
            ForEach(1..<11) { index in
                VStack {
                    Circle()
                        .fill(Color.green.opacity(0.3))
                        .frame(width: 60, height: 60)
                    Text("Item \(index)")
                        .font(.caption)
                }
            }
        }
        .inScrollView(axes: .horizontal)
        .frame(width: 300, height: 150)
        .background(Color.gray.opacity(0.1))
    }
    #endif

    #if DEBUG
    #Preview("Magic ScrollView - With Content Insets") {
        VStack(spacing: 15) {
            ForEach(1..<16) { index in
                Text("Content with padding \(index)")
                    .font(.body)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(6)
            }
        }
        .inScrollView(contentInsets: EdgeInsets(top: 20, leading: 16, bottom: 20, trailing: 16))
        .frame(width: 300, height: 400)
        .background(Color.gray.opacity(0.1))
    }
    #endif

    #if DEBUG
    #Preview("Magic ScrollView - No Indicators") {
        VStack(spacing: 10) {
            ForEach(1..<26) { index in
                Text("No scroll indicators - Item \(index)")
                    .font(.callout)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.purple.opacity(0.1))
            }
        }
        .inScrollView(showsIndicators: false)
        .frame(width: 300, height: 350)
        .background(Color.gray.opacity(0.1))
    }
    #endif
#endif
