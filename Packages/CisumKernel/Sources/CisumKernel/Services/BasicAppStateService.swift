import Combine
import Foundation

/// Kernel 默认提供的轻量级应用状态实现。
///
/// Factory 在真正的 AppState 插件接入前使用它，为插件视图提供稳定的
/// Demo、数据库视图和导入状态上下文。
@MainActor
public final class BasicAppStateService: ObservableObject, AppStateProviding {
    @Published public private(set) var isDemoMode = false
    @Published public private(set) var isDBViewVisible = true
    @Published public private(set) var isImporting = false
    @Published public private(set) var hasDragOperation = false

    public init() {}

    public func enterDemoMode() {
        isDemoMode = true
    }

    public func exitDemoMode() {
        isDemoMode = false
    }

    public func showDBView() {
        isDBViewVisible = true
    }

    public func hideDBView() {
        isDBViewVisible = false
    }

    public func setImporting(_ importing: Bool) {
        isImporting = importing
    }

    public func setDragOperation(_ active: Bool) {
        hasDragOperation = active
    }
}
