import CisumKernel
import SwiftUI

/// 默认 `StatusViewProviding` 实现：返回内置的底部状态区（`StatusView`）。
@MainActor
public final class DefaultStatusViewProviding: StatusViewProviding {
    private let kernel: CisumKernel

    public init(kernel: CisumKernel) {
        self.kernel = kernel
    }

    public func makeStatusView() -> AnyView {
        AnyView(StatusView(kernel: kernel))
    }
}
