import SwiftUI

/// 状态区提供能力协议（对齐 Lumi 各区域独立 Provider 的范式）。
///
/// 定义「内核 → 根布局底部状态区」这一段的最小契约：宿主在装配时通过内核
/// 解析 `StatusViewProviding`，拿到状态视图后注入根布局。该区域是根视图中的
/// 一小块，独立成 Provider 便于替换与解耦。
@MainActor
public protocol StatusViewProviding: AnyObject {
    /// 返回底部状态区视图。
    func makeStatusView() -> AnyView
}
