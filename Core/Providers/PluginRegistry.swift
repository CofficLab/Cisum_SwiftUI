import Foundation
import ObjectiveC.runtime

@objc protocol PluginRegistrant: MagicPluginRegistrant {
    static func register()
}

typealias PluginRegistry = MagicPluginRegistry<any SuperPlugin>
extension PluginRegistry {
    static let shared = PluginRegistry()
}

// App-layer convenience: use instance id as key while keeping existential storage
extension PluginRegistry {
    func register(order: Int = 0, factory: @escaping @Sendable () -> any SuperPlugin) {
        let instance = factory()
        let id = (instance as any MagicSuperPlugin).id
        self.register(id: id, order: order) { instance }
    }

    /// 同步包装，隐藏插件侧的 Task/await 细节
    static func registerSync(order: Int = 0, factory: @escaping @Sendable () -> any SuperPlugin) {
        Task { await PluginRegistry.shared.register(order: order, factory: factory) }
    }
}

@MainActor
func autoRegisterPlugins() { magicAutoRegisterPlugins() }
