import Foundation
import SwiftUI
import MagicKit

/// 音频设置的刷新状态容器（迁移 Phase 5）。
///
/// 持有刷新令牌，存储位置变化时递增以触发设置视图刷新；
/// 取代原 `AudioSettingsPluginView` 的 `@State refreshToken` 与
/// `AudioSettingsStorageChangeModifier`。
@MainActor
final class AudioSettingsViewModel: ObservableObject, SuperLog {
    nonisolated static let verbose = false

    @Published private(set) var refreshToken = 0

    func handleStorageLocationChanged() {
        refreshToken += 1
    }
}
