import Combine
import Foundation

/// Kernel 默认提供的轻量级应用状态实现。
///
/// 吸收了旧版 `AppVM`（Demo 模式、数据库视图显隐、导入/拖放）与 `StateVM`
/// （状态消息频道）的职责，并通过 `UserDefaults` 持久化数据库视图显隐
/// （key `"UI.ShowDB"`，与旧版 `UIRepo` 一致）。
@MainActor
public final class BasicAppStateService: ObservableObject, AppStateProviding {
    private static let showDBKey = "UI.ShowDB"

    @Published public private(set) var isDemoMode = false
    @Published public private(set) var isDBViewVisible: Bool
    @Published public private(set) var isImporting = false
    @Published public private(set) var isDropping = false
    @Published public private(set) var stateMessage = ""

    public var hasDragOperation: Bool { isDropping }

    public init() {
        isDBViewVisible = UserDefaults.standard.bool(forKey: Self.showDBKey)
    }

    public func enterDemoMode() {
        isDemoMode = true
    }

    public func exitDemoMode() {
        isDemoMode = false
    }

    public func showDBView() {
        setDBView(true)
    }

    public func hideDBView() {
        setDBView(false)
    }

    public func closeDBView() {
        setDBView(false)
    }

    public func toggleDBView() {
        setDBView(!isDBViewVisible)
    }

    public func setImporting(_ importing: Bool) {
        isImporting = importing
    }

    public func setDragOperation(_ active: Bool) {
        isDropping = active
    }

    public func appendStateMessage(_ message: String) {
        if stateMessage.isEmpty {
            stateMessage = message
        } else {
            stateMessage += "\n" + message
        }
    }

    public func clearStateMessages() {
        stateMessage = ""
    }

    private func setDBView(_ visible: Bool) {
        guard isDBViewVisible != visible else { return }
        isDBViewVisible = visible
        UserDefaults.standard.set(visible, forKey: Self.showDBKey)
    }
}
