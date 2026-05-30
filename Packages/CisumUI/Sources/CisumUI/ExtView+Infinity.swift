import SwiftUI

public extension View {
    /// 让视图的宽度和高度都扩展到最大可用空间
    /// - Returns: 应用 frame 修饰后的视图
    func infinite() -> some View {
        self.frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    /// 让视图的宽度扩展到最大可用空间
    /// - Returns: 应用 frame 修饰后的视图
    func infiniteWidth() -> some View {
        self.frame(maxWidth: .infinity)
    }

    /// 让视图的高度扩展到最大可用空间
    /// - Returns: 应用 frame 修饰后的视图
    func infiniteHeight() -> some View {
        self.frame(maxHeight: .infinity)
    }
}
