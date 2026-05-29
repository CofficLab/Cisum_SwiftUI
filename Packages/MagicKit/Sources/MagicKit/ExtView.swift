import SwiftUI

extension View {
    /// 让视图仅在 Debug 模式下显示
    /// - Returns: 在 Debug 模式下返回原视图，在 Release 模式下返回空视图
    public func onlyDebug() -> some View {
        #if DEBUG
        return self
        #else
        return EmptyView()
        #endif
    }

    /// 条件性地添加 hover 监听
    /// - Parameters:
    ///   - isEnabled: 是否启用 hover 监听
    ///   - onHover: hover 状态改变时的回调闭包
    /// - Returns: 修改后的视图
    public func conditionalHover(
        isEnabled: Bool,
        perform onHover: @escaping (Bool) -> Void
    ) -> some View {
        modifier(HoverModifier(isEnabled: isEnabled, onHover: onHover))
    }

public func onNotification(_ name: Notification.Name, perform action: @escaping (Notification) -> Void) -> some View {
        self.onReceive(NotificationCenter.default.publisher(for: name), perform: action)
    }
    
    public func onNotification(_ name: Notification.Name, _ action: @escaping (Notification) -> Void) -> some View {
        self.onReceive(NotificationCenter.default.publisher(for: name), perform: action)
    }
}

/// 用于条件性地添加 hover 监听的修饰器
struct HoverModifier: ViewModifier {
    let isEnabled: Bool
    let onHover: (Bool) -> Void
    
    func body(content: Content) -> some View {
        if isEnabled {
            content.onHover(perform: onHover)
        } else {
            content
        }
    }
}
