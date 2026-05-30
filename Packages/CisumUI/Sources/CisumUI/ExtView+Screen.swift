import SwiftUI

public extension View {
    /// 将当前视图包装在 iMac 屏幕中
    /// - Returns: 包装在 iMac 屏幕中的视图
    func inIMacScreen() -> some View {
        iMacScreen {
            self
        }
    }
}

public extension View {
    /// 将当前视图包装在 MacBook 屏幕中
    /// - Returns: 包装在 MacBook 屏幕中的视图
    func inMacBookScreen() -> some View {
        MacBookScreen {
            self
        }
    }
}

public extension View {
    /// 将当前视图包装在 iPhone 屏幕中
    /// - Parameter horizon: 是否使用横屏模式，默认为 false
    /// - Returns: 包装在 iPhone 屏幕中的视图
    func inIPhoneScreen(horizon: Bool = false) -> some View {
        iPhoneScreen(horizon: horizon) {
            self
        }
    }
}

public extension View {
    /// 将当前视图包装在 iPad 屏幕中
    /// - Parameter horizon: 是否使用横屏模式，默认为 false
    /// - Returns: 包装在 iPad 屏幕中的视图
    func inIPadScreen(horizon: Bool = false) -> some View {
        iPadScreen(horizon: horizon) {
            self
        }
    }
}
