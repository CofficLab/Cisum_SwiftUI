import Foundation
import MagicKit
import OSLog
import SwiftData
import SwiftUI

#if os(macOS)
    actor CopyPlugin: SuperPlugin, SuperLog {
        static let emoji = "🚛"
        static let verbose = true
        static var shouldRegister: Bool { true }
        static var order: Int { 0 }
        let description: String = "作为歌曲仓库，只关注文件，文件夹将被忽略"
        let iconName: String = "music.note"

        @MainActor var db: CopyDB? = nil
        @MainActor var worker: CopyWorker? = nil
        @MainActor var container: ModelContainer?

        @MainActor func addStateView(currentSceneName: String?) -> AnyView? {
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
#endif

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}
