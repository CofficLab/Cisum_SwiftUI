import SwiftUI

// MARK: - Button Disabled Extensions

public extension View {
    /// 禁用视图并在点击时显示禁用原因的弹出框
    ///
    /// 当视图被禁用时，点击会弹出一个 popover 显示禁用的原因。
    /// 适用于需要向用户解释为什么某个操作暂时不可用的场景。
    ///
    /// ```swift
    /// Button("提交") { }
    ///     .disabledWithReason("请先填写必填项")
    ///
    /// Button("保存") { }
    ///     .disabledWithReason("网络连接断开，请检查网络设置")
    /// ```
    ///
    /// - Parameter reason: 禁用原因的文本描述
    /// - Returns: 可显示禁用原因的视图
    func disabledWithReason(_ reason: String) -> some View {
        self.modifier(DisabledWithReasonModifier(isDisabled: true, reason: reason))
    }

    /// 根据条件禁用视图并在点击时显示禁用原因的弹出框
    ///
    /// 当条件为 true 时，视图会被禁用，点击会弹出 popover 显示禁用原因。
    ///
    /// ```swift
    /// Button("提交") { }
    ///     .disabledWithReason(isFormValid, reason: "请先填写必填项")
    ///
    /// Button("保存") { }
    ///     .disabledWithReason(isConnected, reason: "网络连接断开")
    /// ```
    ///
    /// - Parameters:
    ///   - disabled: 是否禁用的布尔值
    ///   - reason: 禁用原因的文本描述
    /// - Returns: 可显示禁用原因的视图
    func disabledWithReason(_ disabled: Bool, reason: String) -> some View {
        self.modifier(DisabledWithReasonModifier(isDisabled: disabled, reason: reason))
    }
}

#if DEBUG
#Preview("Button Disabled with Reason") {
    DisabledWithReasonPreviews()
        .frame(width: 500, height: 700)
}
#endif
