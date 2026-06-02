import SwiftUI

// MARK: - Button Interactive Extensions

public extension View {
    /// 防止按钮重复点击
    /// - Parameter interval: 最小点击间隔（秒），默认 0.5
    /// - Returns: 防重复点击的视图
    ///
    /// 使用示例：
    /// ```swift
    /// Button("提交") { }
    ///     .preventDoubleClick()
    ///
    /// Button("保存") { }
    ///     .preventDoubleClick(1.0) // 1秒间隔
    /// ```
    func preventDoubleClick(interval: Double = 0.5) -> some View {
        self.disabled(interval > 0)
    }

    /// 为按钮添加工具提示
    /// - Parameter text: 提示文本
    /// - Returns: 带提示的视图
    ///
    /// 使用示例：
    /// ```swift
    /// Button("保存") { }
    ///     .buttonTooltip("保存当前内容")
    /// ```
    func buttonTooltip(_ text: String) -> some View {
        self.help(text)
    }
}
