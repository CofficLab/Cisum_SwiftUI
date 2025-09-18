import Foundation
import ObjectiveC.runtime

/// MagicPluginRegistry
///
/// 通用的插件注册与自动发现能力，供框架和业务复用：
/// - 线程安全的注册中心 `MagicPluginRegistry<Plugin>`（基于 `actor`）
/// - 基于 Objective‑C Runtime 的自动扫描 `magicAutoRegisterPlugins()`
/// - 自注册协议 `MagicPluginRegistrant`（实现方负责在 `register()` 中登记工厂）
///
/// 设计要点：
/// - 用 `order` 控制插件构建顺序（数字越小越先构建）。
/// - 使用“工厂闭包”惰性创建插件实例，便于解耦。
/// - 将核心实现放在框架层，业务层只做类型别名与转发，便于复用。
///
/// 业务层用法示例（以 `SuperPlugin` 为例）：
/// ```swift
/// typealias PluginRegistry = MagicPluginRegistry<any SuperPlugin>
/// extension PluginRegistry { static let shared = PluginRegistry() }
///
/// @objc final class MyPluginRegistrant: NSObject, MagicPluginRegistrant {
///     static func register() {
///         Task { await PluginRegistry.shared.register(id: "my.plugin", order: 10) { MyPlugin() } }
///     }
/// }
///
/// // 启动时：
/// magicAutoRegisterPlugins()
/// let plugins = await PluginRegistry.shared.buildAll()
/// ```

/// 约定插件在运行时扫描阶段自注册的协议。
@objc protocol MagicPluginRegistrant {
    static func register()
}

/// 线程安全的通用插件注册中心。
actor MagicPluginRegistry<Plugin> {

    private struct FactoryItem {
        let id: String
        let order: Int
        let factory: () -> Plugin
    }

    private var factoryItems: [FactoryItem] = []

    // MARK: - Registry API

    func register(id: String, order: Int = 0, factory: @escaping () -> Plugin) {
        factoryItems.append(FactoryItem(id: id, order: order, factory: factory))
    }

    func buildAll() -> [Plugin] {
        factoryItems
            .sorted { $0.order < $1.order }
            .map { $0.factory() }
    }
}

// MARK: - Auto Registration

/// 扫描运行时类表，触发所有符合 `MagicPluginRegistrant` 的类型执行 `register()`。
@MainActor
func magicAutoRegisterPlugins() {
    var count: UInt32 = 0
    guard let classList = objc_copyClassList(&count) else { return }
    defer { free(UnsafeMutableRawPointer(classList)) }

    let classes = UnsafeBufferPointer(start: classList, count: Int(count))
    for i in 0..<classes.count {
        let cls: AnyClass = classes[i]
        if class_conformsToProtocol(cls, MagicPluginRegistrant.self) {
            (cls as? MagicPluginRegistrant.Type)?.register()
        }
    }
}


