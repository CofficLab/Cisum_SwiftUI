import SwiftUI

/// Error 类型的扩展，提供错误处理和展示相关的功能
///
/// 这个扩展为Swift的Error类型添加了创建错误视图的功能，
/// 使得在SwiftUI应用中可以更方便地展示和处理错误。
///
/// ## 使用示例:
/// ```swift
/// do {
///     try someRiskyOperation()
/// } catch let error {
///     // 创建错误视图并显示
///     let errorView = error.makeView()
///     // 使用errorView...
/// }
/// ```
public extension Error {
    /// 创建一个用于展示该错误的视图
    /// - Parameters:
    ///   - title: 可选的标题，如果不提供则使用默认标题
    ///   - onDismiss: 可选的关闭回调
    /// - Returns: 包含错误详情的视图
    func makeView(title: String? = nil, onDismiss: (() -> Void)? = nil) -> MagicErrorView {
        MagicErrorView(error: self, title: title, onDismiss: onDismiss)
    }

    /// 复制错误信息
    func copy() {
        self.localizedDescription.copy()
    }
}
