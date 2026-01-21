import Foundation
import MagicKit
import OSLog
import SwiftUI

actor BookPlugin: SuperPlugin, SuperLog, PluginRegistrant {
    static let keyOfCurrentBookURL = "com.bookplugin.currentBookURL"
    static let keyOfCurrentBookTime = "com.bookplugin.currentBookTime"
    nonisolated static var emoji: String { "🎺" }
    private static var verbose: Bool { true }
    private static var enabled: Bool { false }

    let title: String = "有声书"
    let description: String = "适用于听有声书的场景"
    let iconName: String = "book"
    static let dirName = "audios_book"
    let isGroup: Bool = true    

    @MainActor var disk: URL?

    @MainActor func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View {
        AnyView(BookRootView { content() })
    }

    @MainActor
    func onWillAppear(playMan: PlayMan, currentGroup: (any SuperPlugin)?, storage: StorageLocation?) async throws {
        guard let currentGroup = currentGroup, currentGroup.label == self.label else {
            return
        }

        self.disk = Config.cloudDocumentsDir?.appendingFolder(Self.dirName)
    }
    
    @MainActor
    static func getBookDisk() -> URL? {
        guard let storageRoot = Config.getStorageRoot() else {
            return nil
        }
        
        let disk = try? storageRoot.appendingPathComponent(Self.dirName, isDirectory: true).createIfNotExist()
        
        return disk
    }
}

// MARK: - PluginRegistrant
extension BookPlugin {
    @objc static func register() {
        guard Self.enabled else {
            return
        }

        Task {
            if Self.verbose {
                os_log("\(self.t)🚀🚀🚀 Register")
            }

            await PluginRegistry.shared.register(order: 1) {
                BookPlugin()
            }
        }
    }
}

#if os(macOS)
    #Preview("App - Large") {
        ContentView()
    .inRootView()
            .frame(width: 600, height: 1000)
    }

    #Preview("App - Small") {
        ContentView()
    .inRootView()
            .frame(width: 500, height: 800)
    }
#endif // os(macOS)

#if os(iOS)
    #Preview("iPhone") {
        ContentView()
    .inRootView()
    }
#endif
