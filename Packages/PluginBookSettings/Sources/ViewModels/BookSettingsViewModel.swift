import Foundation
import SwiftUI
import MagicKit

/// 书籍设置的刷新状态容器（迁移 Phase 5）。
///
/// 持有刷新令牌，存储位置变化时递增以触发设置视图刷新；
/// 取代原 `BookSettingsPluginView` 的 `@State refreshToken` 与
/// `BookSettingsStorageChangeModifier`。
@MainActor
final class BookSettingsViewModel: ObservableObject, SuperLog {
    nonisolated static let verbose = false

    @Published private(set) var refreshToken = 0

    func handleStorageLocationChanged() {
        refreshToken += 1
    }
}
