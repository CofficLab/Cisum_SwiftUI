import Foundation
import MagicCore
import OSLog
import SwiftData
import SwiftUI

#if os(macOS)
actor CopyPlugin: SuperPlugin, SuperLog, PluginRegistrant {
    static let emoji = "🚛"

    let description: String = "作为歌曲仓库，只关注文件，文件夹将被忽略"
    let iconName: String = "music.note"
    let isGroup: Bool = false
    @MainActor var db: CopyDB? = nil
    @MainActor var worker: CopyWorker? = nil
    @MainActor var container: ModelContainer?

    @MainActor func addStateView(currentGroup: SuperPlugin?) -> AnyView? {
        return AnyView(
            CopyStateView()
        )
    }

    @MainActor func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View {
        return AnyView(
            CopyRootView { content() }
        )
    }
}

// MARK: - PluginRegistrant

extension CopyPlugin {
    @objc static func register() {
        PluginRegistry.registerSync(order: 0) { Self() }
    }
}
#endif
