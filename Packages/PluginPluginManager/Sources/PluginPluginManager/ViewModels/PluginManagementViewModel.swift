import Combine
import Foundation

/// 插件管理视图的状态容器（迁移 Phase 4）。
///
/// 持有插件启停变化的版本号，收到通知时递增以强制列表重建；
/// 取代原 `PluginManagementView` 的 `@State revision` + `.onReceive`。
@MainActor
final class PluginManagementViewModel: ObservableObject {
    /// 插件启停变化版本号：递增时强制列表重建。
    @Published private(set) var revision = 0

    func incrementRevision() {
        revision += 1
    }
}
