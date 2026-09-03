import SwiftUI

/// 默认 `ControlViewProviding` 实现：返回内置的播放控制区（`ControlView`）。
@MainActor
public final class DefaultControlViewProviding: ControlViewProviding {
    private let stateViews: @MainActor () -> [AnyView]
    private let stateMessage: @MainActor () -> String
    private let toggleDBView: @MainActor () -> Void

    public init(
        stateViews: @escaping @MainActor () -> [AnyView] = { [] },
        stateMessage: @escaping @MainActor () -> String = { "" },
        toggleDBView: @escaping @MainActor () -> Void = {}
    ) {
        self.stateViews = stateViews
        self.stateMessage = stateMessage
        self.toggleDBView = toggleDBView
    }

    public func makeControlView() -> AnyView {
        AnyView(
            ControlView(
                stateViews: stateViews,
                stateMessage: stateMessage,
                toggleDBView: toggleDBView
            )
        )
    }
}
