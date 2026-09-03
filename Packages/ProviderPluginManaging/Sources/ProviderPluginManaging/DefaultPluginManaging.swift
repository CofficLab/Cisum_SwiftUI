import KernelCore
import CisumUIComponents
import Foundation

/// 直接读取 `BuiltinPluginManager` 的插件管理实现。
@MainActor
public final class DefaultPluginManaging: PluginManaging {
    public private(set) var lastErrorDescription: String?
    private let manager: BuiltinPluginManager
    private weak var kernel: CisumKernel?

    private var observerCallbacks: [UUID: (PluginManagingEvent) -> Void] = [:]
    private var notificationToken: NSObjectProtocol?

    public init(manager: BuiltinPluginManager, kernel: CisumKernel) {
        self.manager = manager
        self.kernel = kernel

        // 订阅内核的已启用插件变更通知，转发为 Provider 语义事件。
        notificationToken = NotificationCenter.default.addObserver(
            forName: .cisumEnabledPluginsDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.send(.enabledPluginsChanged)
            }
        }
    }

    // MARK: - PluginManaging

    public var allPlugins: [any SuperPlugin] {
        manager.allPlugins
    }

    public var configurablePlugins: [any SuperPlugin] {
        manager.allPlugins.filter { type(of: $0).metadata.policy.allowUserToggle }
    }

    public var pluginCount: Int {
        manager.allPlugins.count
    }

    public var enabledCount: Int {
        manager.enabledPlugins.count
    }

    public func plugin(id: String) -> (any SuperPlugin)? {
        manager.plugin(by: id)
    }

    public func isRegistered(id: String) -> Bool {
        manager.plugin(by: id) != nil
    }

    public func enabledPlugins(from candidates: [any SuperPlugin]) -> [any SuperPlugin] {
        candidates.filter { manager.isPluginEnabled($0) }
    }

    // MARK: - Plugin Control

    public func enablePlugin(id: String) async -> Bool {
        guard let kernel else {
            lastErrorDescription = "Kernel is not available"
            return false
        }
        do {
            try await manager.enablePlugin(id: id, kernel: kernel)
            lastErrorDescription = nil
            return true
        } catch {
            lastErrorDescription = error.localizedDescription
            return false
        }
    }

    public func disablePlugin(id: String) async -> Bool {
        guard let kernel else {
            lastErrorDescription = "Kernel is not available"
            return false
        }
        do {
            try await manager.disablePlugin(id: id, kernel: kernel)
            lastErrorDescription = nil
            return true
        } catch {
            lastErrorDescription = error.localizedDescription
            return false
        }
    }

    public func isEnabled(id: String) -> Bool {
        guard let plugin = manager.plugin(by: id) else { return false }
        return manager.isPluginEnabled(plugin)
    }

    // MARK: - PluginManaging Observer

    public func addObserver(
        _ callback: @escaping (PluginManagingEvent) -> Void
    ) -> any PluginManagingObserverHandle {
        let id = UUID()
        observerCallbacks[id] = callback
        return PluginManagingObserverHandleBox(owner: self, id: id)
    }

    private func send(_ event: PluginManagingEvent) {
        let activeCallbacks = Array(observerCallbacks.values)
        for callback in activeCallbacks {
            callback(event)
        }
    }

    fileprivate func removeObserver(id: UUID) {
        observerCallbacks.removeValue(forKey: id)
    }
}

/// 插件管理监听句柄实现；`cancel()` 后从所属 Provider 移除回调。
@MainActor
private final class PluginManagingObserverHandleBox: PluginManagingObserverHandle {
    private weak var owner: DefaultPluginManaging?
    private let id: UUID
    private var isCancelled = false

    init(owner: DefaultPluginManaging, id: UUID) {
        self.owner = owner
        self.id = id
    }

    func cancel() {
        guard !isCancelled else { return }
        isCancelled = true
        owner?.removeObserver(id: id)
    }
}
