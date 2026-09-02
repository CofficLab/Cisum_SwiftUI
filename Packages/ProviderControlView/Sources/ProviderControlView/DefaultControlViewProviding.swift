import SwiftUI

/// 默认 `ControlViewProviding` 实现：返回内置的播放控制区（`ControlView`）。
@MainActor
public final class DefaultControlViewProviding: ControlViewProviding {
    public init() {}

    public func makeControlView() -> AnyView {
        AnyView(ControlView())
    }
}
