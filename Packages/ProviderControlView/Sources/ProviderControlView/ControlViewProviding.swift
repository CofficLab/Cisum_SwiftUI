import SwiftUI

/// 播放控制区提供能力协议（对齐 Lumi 各区域独立 Provider 的范式）。
///
/// 定义「内核 → 根布局顶部播放控制区」这一段的最小契约：宿主在装配时
/// 通过内核解析 `ControlViewProviding`，拿到播放控制视图后注入根布局。
/// 该区域是根视图中的一小块，独立成 Provider 便于替换与解耦。
@MainActor
public protocol ControlViewProviding: AnyObject {
    /// 返回顶部播放控制区视图。
    func makeControlView() -> AnyView
}
