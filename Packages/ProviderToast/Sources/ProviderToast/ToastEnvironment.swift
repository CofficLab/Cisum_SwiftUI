import SwiftUI

private struct ToastProvidingEnvironmentKey: EnvironmentKey {
    static let defaultValue: (any ToastProviding)? = nil
}

public extension EnvironmentValues {
    /// 当前窗口可用的 Toast Provider；视图通常只需依赖此环境能力。
    var toastProviding: (any ToastProviding)? {
        get { self[ToastProvidingEnvironmentKey.self] }
        set { self[ToastProvidingEnvironmentKey.self] = newValue }
    }
}
