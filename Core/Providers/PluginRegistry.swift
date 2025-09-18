import Foundation
import ObjectiveC.runtime

/// PluginRegistry
///
/// 该文件提供两种能力：
/// - 一个轻量的插件注册中心 `PluginRegistry`（基于 `actor`，线程安全），
///   用于在应用启动时注册插件工厂并按顺序构建插件实例。
/// - 一个基于 Objective-C Runtime 的自动注册方法 `autoRegisterPlugins()`，
///   会遍历运行时类表，查找符合 `PluginRegistrant` 协议的类型并调用其 `register()` 完成自注册。
///
/// 使用方式（示例）：
/// ```swift
/// final class MyPlugin: SuperPlugin { /* ... */ }
///
/// @objc final class MyPluginRegistrant: NSObject, PluginRegistrant {
///     static func register() {
///         Task { await PluginRegistry.shared.register(id: "my.plugin", order: 10) { MyPlugin() } }
///     }
/// }
///
/// // 应用启动时：
/// autoRegisterPlugins()
/// let plugins = await PluginRegistry.shared.buildAll()
/// ```
///
/// 设计意图：
/// - 通过 `actor` 保证并发环境下注册与读取的安全性。
/// - 通过 `order` 提供插件初始化顺序控制（数值越小越先构建）。
/// - 通过运行时扫描实现“零手工汇总”的自动发现/注册，避免在中心化文件里维护长列表。

// MARK: - Types

/// 约定插件自注册的协议。
///
/// 符合该协议的类型（通常是 `@objc final class XxxRegistrant: NSObject`）
/// 将在 `autoRegisterPlugins()` 扫描时被发现，并调用其 `register()` 完成向
/// `PluginRegistry` 的注册。
@objc protocol PluginRegistrant {
    /// 在此方法中调用 `PluginRegistry.shared.register(...)` 完成注册。
    static func register()
}

/// 线程安全的插件注册中心。
///
/// - 通过 `register(id:order:factory:)` 登记插件工厂
/// - 通过 `buildAll()` 依据 `order` 生成插件实例数组
actor PluginRegistry {
    static let shared = PluginRegistry()

    private struct FactoryItem {
        let id: String
        let order: Int
        let factory: () -> any SuperPlugin
    }

    private var factoryItems: [FactoryItem] = []

    // MARK: - Registry API

    /// 登记一个插件工厂。
    /// - Parameters:
    ///   - id: 插件唯一标识（用于排查与调试）。
    ///   - order: 构建顺序，数值越小越先构建，默认 `0`。
    ///   - factory: 创建插件实例的闭包。
    func register(id: String, order: Int = 0, factory: @escaping () -> any SuperPlugin) {
        factoryItems.append(FactoryItem(id: id, order: order, factory: factory))
    }

    /// 按照 `order` 排序并构建所有已登记的插件实例。
    /// - Returns: 插件实例数组。
    func buildAll() -> [any SuperPlugin] {
        factoryItems
            .sorted { $0.order < $1.order }
            .map { $0.factory() }
    }
}

// MARK: - Auto Registration

/// 扫描运行时类表，自动触发所有符合 `PluginRegistrant` 协议类型的 `register()`。
///
/// 注意：
/// - 该函数在主线程（标记为 `@MainActor`）调用，便于与应用启动流程对齐。
/// - 仅用于触发“注册动作”，实际插件构建通过 `PluginRegistry.buildAll()` 完成。
@MainActor
func autoRegisterPlugins() {
    var count: UInt32 = 0
    guard let classList = objc_copyClassList(&count) else { return }
    defer { free(UnsafeMutableRawPointer(classList)) }

    let classes = UnsafeBufferPointer(start: classList, count: Int(count))
    for i in 0..<classes.count {
        let cls: AnyClass = classes[i]
        if class_conformsToProtocol(cls, PluginRegistrant.self) {
            (cls as? PluginRegistrant.Type)?.register()
        }
    }
}
