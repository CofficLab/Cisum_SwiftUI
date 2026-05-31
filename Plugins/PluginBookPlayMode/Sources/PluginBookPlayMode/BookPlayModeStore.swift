import Foundation
import MagicKit
import MagicPlayMan
import OSLog

public actor BookPlayModeStore: SuperLog {
    public static let emoji = "💾"
    public static let verbose = false

    public static let shared = BookPlayModeStore()

    private static let playModeKey = "bookPlayMode"

    private init() {}

    public func getPlayMode() -> MagicPlayMode {
        if let mode = UserDefaults.standard.string(forKey: Self.playModeKey),
           let playMode = MagicPlayMode(rawValue: mode) {
            return playMode
        }

        if let modeString = NSUbiquitousKeyValueStore.default.string(forKey: Self.playModeKey),
           let playMode = MagicPlayMode(rawValue: modeString) {
            return playMode
        }

        return .sequence
    }

    public func storePlayMode(_ mode: MagicPlayMode) {
        UserDefaults.standard.set(mode.rawValue, forKey: Self.playModeKey)
        NSUbiquitousKeyValueStore.default.set(mode.rawValue, forKey: Self.playModeKey)
        NSUbiquitousKeyValueStore.default.synchronize()

        if Self.verbose {
            os_log("\(self.t)💾 保存书籍播放模式: \(mode.shortName)")
        }
    }
}
