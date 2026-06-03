import MagicKit
import OSLog
import SwiftUI

/// 应用程序的内容布局配置组件
/// 提供对 ContentView 的配置能力，通过修饰符方法控制布局行为
struct ContentLayout: View, SuperLog {
    nonisolated static let emoji = "📐"
    nonisolated static let verbose = false

    @EnvironmentObject var app: AppVM
    @EnvironmentObject var p: PluginVM

    private(set) var isDetailVisible: Bool

    /// 初始化内容布局
    /// - Parameter showDetail: 默认显示详情视图
    init(showDetail: Bool = false) {
        self.isDetailVisible = showDetail
    }

    var body: some View {
        ContentView(isDetailVisible: isDetailVisible)
            .frame(idealHeight: Config.idealHeight)
    }
}

// MARK: - Modifier

extension ContentLayout {
    /// 启用显示详情视图
    /// - Returns: 启用显示详情视图的新 ContentLayout 实例
    func showDetail() -> ContentLayout {
        return ContentLayout(showDetail: true)
    }

    /// 禁用显示详情视图
    /// - Returns: 禁用显示详情视图的新 ContentLayout 实例
    func hideDetail() -> ContentLayout {
        return ContentLayout(showDetail: false)
    }
}

// MARK: - Preview

#Preview("ContentLayout") {
    ContentLayout()
        .inRootView()
        .withDebugBar()
}

#Preview("ContentLayout - Show Detail") {
    ContentLayout()
        .showDetail()
        .inRootView()
        .withDebugBar()
}

#Preview("ContentLayout - Hide Detail") {
    ContentLayout()
        .hideDetail()
        .inRootView()
        .withDebugBar()
}
