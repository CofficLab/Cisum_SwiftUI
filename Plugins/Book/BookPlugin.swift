import Foundation
import MagicKit
import OSLog
import SwiftUI

actor BookPlugin: SuperPlugin, SuperLog {
    static let keyOfCurrentBookURL = "com.bookplugin.currentBookURL"
    static let keyOfCurrentBookTime = "com.bookplugin.currentBookTime"
    nonisolated static var emoji: String { "🎺" }
    private static var verbose: Bool { true }
    static var shouldRegister: Bool { false } // 暂时禁用有声书插件

    /// 注册顺序设为 1，与 AudioPlugin 相同优先级
    static var order: Int { 1 }

    let title: String = "有声书"
    let description: String = "有声书播放功能"
    let iconName: String = "book"
    static let dirName = "audios_book"

    /// 提供"有声书"场景
    @MainActor func addSceneItem() -> String? {
        return "有声书"
    }

    @MainActor var disk: URL?

    @MainActor func addRootView<Content>(@ViewBuilder content: () -> Content) -> AnyView? where Content: View {
        AnyView(BookRootView { content() })
    }

    @MainActor
    func onWillAppear(playMan: PlayMan, currentSceneName: String?, storage: StorageLocation?) async throws {
        guard currentSceneName == self.addSceneItem() else {
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
