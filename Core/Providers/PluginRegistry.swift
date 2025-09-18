import Foundation
import ObjectiveC.runtime

@objc protocol PluginRegistrant: MagicPluginRegistrant {
    static func register()
}

typealias PluginRegistry = MagicPluginRegistry<any SuperPlugin>
extension PluginRegistry {
    static let shared = PluginRegistry()
}

@MainActor
func autoRegisterPlugins() { magicAutoRegisterPlugins() }
