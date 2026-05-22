import SwiftUI

public extension View {
    /// 在水平方向占满可用宽度（等同 `frame(maxWidth: .infinity)`）。
    func infiniteWidth(alignment: Alignment = .center) -> some View {
        frame(maxWidth: .infinity, alignment: alignment)
    }
}
