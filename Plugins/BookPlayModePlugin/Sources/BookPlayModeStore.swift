import Foundation
import CisumUI
import MagicPlayMan
import OSLog

public actor BookPlayModeStore: SuperLog {
    public static let emoji = "💾"
    public static let verbose = false

    public static let shared = BookPlayModeStore()

    private static let playModeKey = "bookPlayMode"

    private init() {}

    public func getPlayMode() -> MagicPlayMode {
        Self.resolvedPlayMode(
            localRawValue: UserDefaults.standard.string(forKey: Self.playModeKey),
            cloudRawValue: NSUbiquitousKeyValueStore.default.string(forKey: Self.playModeKey)
        )
    }

    static func resolvedPlayMode(localRawValue: String?, cloudRawValue: String?) -> MagicPlayMode {
        if let localRawValue, let playMode = MagicPlayMode(rawValue: localRawValue) {
            return playMode
        }

        if let cloudRawValue, let playMode = MagicPlayMode(rawValue: cloudRawValue) {
            return playMode
        }

        return .sequence
    }

    public func storePlayMode(_ mode: MagicPlayMode) {
        UserDefaults.standard.set(mode.rawValue, forKey: Self.playModeKey)
        NSUbiquitousKeyValueStore.default.set(mode.rawValue, forKey: Self.playModeKey)
        NSUbiquitousKeyValueStore.default.synchronize()

        if Self.verbose {
            os_log("\(self.t)💾 Saved audiobook play mode: \(mode.shortName)")
        }
    }
}
