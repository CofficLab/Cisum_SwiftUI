import Foundation
import ObjectiveC.runtime

@objc protocol PluginRegistrant: MagicPluginRegistrant {
    static func register()
}

typealias PluginRegistry = MagicPluginRegistry<any SuperPlugin>
extension PluginRegistry {
    nonisolated(unsafe) static let shared = PluginRegistry()
}

// App-layer convenience: use instance id as key while keeping existential storage
extension PluginRegistry {
    func register(order: Int = 0, factory: @escaping @Sendable () -> any SuperPlugin) {
        let instance = factory()
        let id = (instance as any MagicSuperPlugin).id
        self.register(id: id, order: order) { instance }
    }

    /// 同步注册插件（已改为真正的同步）
    static func registerSync(order: Int = 0, factory: @escaping @Sendable () -> any SuperPlugin) {
        PluginRegistry.shared.register(order: order, factory: factory)
    }
}

func autoRegisterPlugins() { magicAutoRegisterPlugins() }
