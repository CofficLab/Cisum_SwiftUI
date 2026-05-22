import Foundation
import OSLog
import SwiftUI

actor AudioPlayModeRepo: SuperLog {
    static let emoji = "💾"
    static let verbose = false

    /// 单例实例
    static let shared = AudioPlayModeRepo()

    /// UserDefaults 键名
    private static let playModeKey = "audioPlayMode"

    private init() {}

    /// 获取当前播放模式
    /// - Returns: 当前播放模式，如果没有设置则返回默认模式
    func getPlayMode() -> PlayMode {
        // 首先尝试从 UserDefaults 获取模式
        if let mode = UserDefaults.standard.string(forKey: Self.playModeKey),
           let playMode = PlayMode(rawValue: mode) {
            return playMode
        }

        // 如果在 UserDefaults 中未找到，尝试从 iCloud 获取
        if let modeString = NSUbiquitousKeyValueStore.default.string(forKey: Self.playModeKey),
           let playMode = PlayMode(rawValue: modeString) {
            return playMode
        }

        return .sequence // 默认顺序播放
    }

    /// 保存播放模式
    /// - Parameter mode: 要保存的播放模式
    func storePlayMode(_ mode: PlayMode) {
        storePlayModeRawValue(mode.rawValue, shortName: mode.shortName)
    }

    /// 保存播放模式
    /// - Parameters:
    ///   - modeString: 播放模式的原始值
    ///   - shortName: 用于日志输出的模式名称
    func storePlayModeRawValue(_ modeString: String, shortName: String) {
        UserDefaults.standard.set(modeString, forKey: Self.playModeKey)

        // 将模式同步到 CloudKit
        NSUbiquitousKeyValueStore.default.set(modeString, forKey: Self.playModeKey)
        NSUbiquitousKeyValueStore.default.synchronize()

        if Self.verbose {
            os_log("\(self.t)💾 保存播放模式: \(shortName)")
        }
    }

    /// 重置为默认播放模式
    func resetToDefault() {
        let defaultMode = PlayMode.sequence
        storePlayMode(defaultMode)

        if Self.verbose {
            os_log("\(self.t)🔄 重置播放模式为默认: \(defaultMode.shortName)")
        }
    }

    /// 获取所有可用的播放模式
    /// - Returns: 播放模式数组
    func getAvailableModes() -> [PlayMode] {
        [.sequence, .repeatAll, .loop, .shuffle]
    }

    /// 检查指定的播放模式是否可用
    /// - Parameter mode: 要检查的播放模式
    /// - Returns: 是否可用
    func isModeAvailable(_ mode: PlayMode) -> Bool {
        getAvailableModes().contains(mode)
    }
}

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}
