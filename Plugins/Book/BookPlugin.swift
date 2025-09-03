import Foundation
import MagicCore
import OSLog
import SwiftUI

actor BookPlugin: SuperPlugin, SuperLog {
    static let keyOfCurrentBookURL = "com.bookplugin.currentBookURL"
    static let keyOfCurrentBookTime = "com.bookplugin.currentBookTime"

    static let emoji = "🎺"
    let label: String = "Book"
    let hasPoster: Bool = true
    let description: String = "适用于听有声书的场景"
    let iconName: String = "book"
    let dirName = "audios_book"
    let isGroup: Bool = true

    @MainActor var disk: URL?

    @MainActor func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View {
        AnyView(BookRootView { content() })
    }

    @MainActor func addDBView(reason: String) -> AnyView? {
        os_log("\(self.t)生成DBView")

        return AnyView(BookDBView())
    }

    @MainActor
    func addPosterView() -> AnyView? { AnyView(BookPoster()) }

    @MainActor
    func onWillAppear(playMan: PlayManWrapper, currentGroup: (any SuperPlugin)?, storage: StorageLocation?) async throws {
        guard let currentGroup = currentGroup, currentGroup.label == self.label else {
            return
        }

        self.disk = Config.cloudDocumentsDir?.appendingFolder(self.dirName)
    }
}

#if os(macOS)
    #Preview("App - Large") {
        AppPreview()
            .frame(width: 600, height: 1000)
    }

    #Preview("App - Small") {
        AppPreview()
            .frame(width: 500, height: 800)
    }
#endif

#if os(iOS)
    #Preview("iPhone") {
        AppPreview()
    }
#endif
