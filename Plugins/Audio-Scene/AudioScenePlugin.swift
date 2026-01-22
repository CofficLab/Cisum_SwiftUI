import Foundation
import MagicKit
import OSLog
import SwiftData
import SwiftUI

actor AudioScenePlugin: SuperPlugin {
    static var shouldRegister: Bool { true }
    static var order: Int { 0 }
    let title = "音乐场景"
    let description = "提供音乐库场景"
    let iconName = "music.note.list"
    static let sceneName = "音乐库"

    /// 提供"音乐库"场景
    @MainActor func addSceneItem() -> String? {
        return Self.sceneName
    }

    /// 提供音频海报视图
    @MainActor
    func addPosterView() -> AnyView? {
        AnyView(AudioPoster())
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
