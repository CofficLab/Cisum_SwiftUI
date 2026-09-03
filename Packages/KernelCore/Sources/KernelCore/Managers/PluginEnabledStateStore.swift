import Foundation

/// 插件启用状态持久化存储。
///
/// 保存用户对每个可配置插件（`PluginPolicy` 为 `optOut` 或 `optIn`）的启用/禁用覆盖。
/// 以 `[pluginID: Bool]` 形式存入 `UserDefaults`，跨启动保留。
///
/// ## 有效启用状态解析
///
/// - `alwaysOn` 策略: 始终启用，忽略覆盖。
/// - `disabled` 策略: 始终禁用，忽略覆盖。
/// - `optOut` 策略: 优先读取覆盖值，缺省时为 `true`。
/// - `optIn` 策略: 优先读取覆盖值，缺省时为 `false`。
@MainActor
final class PluginEnabledStateStore {
    /// UserDefaults 键。
    private let storageKey = "com.coffic.cisum.pluginEnabledOverrides"

    /// 内存缓存，启动时一次性载入。
    private var cache: [String: Bool]

    init() {
        cache = Self.load(key: storageKey)
    }

    /// 读取某个插件的用户覆盖值；`nil` 表示用户未设置（应回到默认值）。
    func override(for id: String) -> Bool? {
        cache[id]
    }

    /// 设置某个插件的用户覆盖值并持久化。
    func setOverride(_ enabled: Bool, for id: String) {
        cache[id] = enabled
        persist()
    }

    /// 清除某个插件的用户覆盖值（回到默认值）。
    func clearOverride(for id: String) {
        cache.removeValue(forKey: id)
        persist()
    }

    /// 清除所有覆盖值。
    func reset() {
        cache.removeAll()
        persist()
    }

    // MARK: - Persistence

    private func persist() {
        let defaults = UserDefaults.standard
        if cache.isEmpty {
            defaults.removeObject(forKey: storageKey)
        } else {
            defaults.set(cache, forKey: storageKey)
        }
    }

    private static func load(key: String) -> [String: Bool] {
        guard let dict = UserDefaults.standard.dictionary(forKey: key) as? [String: Bool] else {
            return [:]
        }
        return dict
    }
}
