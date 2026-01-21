import Foundation
import MagicKit
import OSLog
import SwiftData
import SwiftUI

actor BookScenePlugin: SuperPlugin, SuperLog {
    static let emoji = "📚"
    static let verbose = true

    /// 注册顺序设为 0，确保最先执行，先提供场景
    static var order: Int { 0 }

    let title = "有声书场景"
    let description = "提供有声书场景"
    let iconName = "book.closed"

    /// 场景名称
    static let sceneName = "有声书"

    /// 提供"有声书"场景
    @MainActor func addSceneItem() -> String? {
        return Self.sceneName
    }
}

// MARK: - Preview

#if os(macOS)
#Preview("App - Large") {
    ContentView()
    .inRootView()
        .frame(width: 600, height: 1000)
}

#Preview("App - Small") {
    ContentView()
    .inRootView()
        .frame(width: 600, height: 600)
}
#endif

#if os(iOS)
#Preview("iPhone") {
    ContentView()
    .inRootView()
}
#endif
