import Foundation
import MagicKit
import OSLog
import SwiftData
import SwiftUI

actor BookScenePlugin: SuperPlugin {
    static let shared = BookScenePlugin()
    static var shouldRegister: Bool { true }
    static var order: Int { 0 }
    nonisolated var title: String { String(localized: "Audiobook Scene", table: "Book-Scene") }
    nonisolated var description: String { String(localized: "Provides audiobook scene", table: "Book-Scene") }
    let iconName = "book.closed"
    static let sceneName = "Audiobooks"

    /// Provides "Audiobooks" scene
    @MainActor func addSceneItem() -> String? {
        return Self.sceneName
    }

    /// 提供有声书封面视图
    @MainActor
    func addPosterView() -> AnyView? {
        AnyView(BookPoster())
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
