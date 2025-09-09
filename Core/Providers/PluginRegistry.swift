import Foundation
import ObjectiveC.runtime

@objc protocol PluginRegistrant {
    static func register()
}

actor PluginRegistry {
    static let shared = PluginRegistry()

    private struct FactoryItem {
        let id: String
        let order: Int
        let factory: () -> any SuperPlugin
    }

    private var factoryItems: [FactoryItem] = []

    func register(id: String, order: Int = 0, factory: @escaping () -> any SuperPlugin) {
        factoryItems.append(FactoryItem(id: id, order: order, factory: factory))
    }

    func buildAll() -> [any SuperPlugin] {
        factoryItems
            .sorted { $0.order < $1.order }
            .map { $0.factory() }
    }
}

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
