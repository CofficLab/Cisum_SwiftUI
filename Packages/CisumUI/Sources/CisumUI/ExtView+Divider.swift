import SwiftUI

/// View扩展 - 分隔线相关
public extension View {
    /// 将视图与分隔线包装在VStack中
    ///
    /// 使用这个方法可以在视图下方添加一个分隔线
    /// 主要用于列表项的分隔或内容分区
    ///
    /// ```swift
    /// Text("Hello")
    ///     .withDivider()
    /// ```
    ///
    /// - Returns: 包装在VStack中的视图和分隔线
    func withDivider() -> some View {
        VStack(spacing: 0) {
            self
            Divider()
        }
    }

    /// 将视图与分隔线包装在VStack中，并指定间距
    ///
    /// ```swift
    /// Text("Hello")
    ///     .withDivider(spacing: 10)
    /// ```
    ///
    /// - Parameter spacing: 视图与分隔线之间的间距
    /// - Returns: 包装在VStack中的视图和分隔线
    func withDivider(spacing: CGFloat) -> some View {
        VStack(spacing: spacing) {
            self
            Divider()
        }
    }

    /// 将视图与自定义分隔线包装在VStack中
    ///
    /// ```swift
    /// Text("Hello")
    ///     .withDivider {
    ///         Rectangle()
    ///             .fill(.blue)
    ///             .frame(height: 2)
    ///     }
    /// ```
    ///
    /// - Parameter divider: 自定义分隔线视图构建器
    /// - Returns: 包装在VStack中的视图和分隔线
    func withDivider<DividerContent: View>(
        @ViewBuilder divider: () -> DividerContent
    ) -> some View {
        VStack(spacing: 0) {
            self
            divider()
        }
    }

    /// 将视图与自定义分隔线（带间距）包装在VStack中
    ///
    /// ```swift
    /// Text("Hello")
    ///     .withDivider(spacing: 10) {
    ///         Rectangle()
    ///             .fill(.blue)
    ///             .frame(height: 2)
    ///     }
    /// ```
    ///
    /// - Parameters:
    ///   - spacing: 视图与分隔线之间的间距
    ///   - divider: 自定义分隔线视图构建器
    /// - Returns: 包装在VStack中的视图和分隔线
    func withDivider<DividerContent: View>(
        spacing: CGFloat,
        @ViewBuilder divider: () -> DividerContent
    ) -> some View {
        VStack(spacing: spacing) {
            self
            divider()
        }
    }
}

// MARK: - Preview

#if DEBUG
    /// 分隔线扩展预览
    struct DividerExtensionPreview: View {
        var body: some View {
            VStack(spacing: 20) {
                Text("Divider Extension Examples")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Text with default divider")
                    .withDivider()

                Text("Text with custom spacing")
                    .withDivider(spacing: 20)

                HStack {
                    Image(systemName: "star.fill")
                    Text("Icon + Text with divider")
                }
                .withDivider()

                VStack(alignment: .leading) {
                    Text("Section 1")
                    Text("Content here")
                }
                .padding()
                .inCardUltraThin()
                .withDivider(spacing: 15)

                HStack {
                    Text("Left")
                    Spacer()
                    Text("Right")
                }
                .withDivider(spacing: 10) {
                    Rectangle()
                        .fill(.blue.opacity(0.5))
                        .frame(height: 2)
                }
            }
            .padding()
        }
    }

    #if DEBUG
    #Preview("Divider Extensions") {
        DividerExtensionPreview()
            .frame(height: 600)
            .frame(width: 400)
    }
    #endif
#endif
