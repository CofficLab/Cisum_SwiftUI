import SwiftUI

// MARK: - Environment Key for Tab View Visibility

struct TabViewVisibilityKey: EnvironmentKey {
    static let defaultValue: Bool = true
}

extension EnvironmentValues {
    /// 控制是否显示 Tab 视图
    var showTabView: Bool {
        get { self[TabViewVisibilityKey.self] }
        set { self[TabViewVisibilityKey.self] = newValue }
    }
}

// MARK: - View Extension

extension View {
    /// 隐藏 Tab 视图
    /// 通过设置环境变量控制，在视图初始化时生效
    func hideTabView() -> some View {
        self.environment(\.showTabView, false)
    }

    /// 显示 Tab 视图
    /// 通过设置环境变量控制，在视图初始化时生效
    func showTabView() -> some View {
        self.environment(\.showTabView, true)
    }
}

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}
