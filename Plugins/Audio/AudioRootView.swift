import Foundation
import MagicAlert
import MagicKit
import MagicPlayMan
import OSLog
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct AudioRootView<Content>: View, SuperLog where Content: View {
    nonisolated static var emoji: String { "📢" }
    nonisolated static var verbose: Bool { false }
    
    @EnvironmentObject var man: PlayManController
    @EnvironmentObject var m: MagicMessageProvider
    @EnvironmentObject var p: PluginProvider
    @EnvironmentObject var app: AppProvider

    @State private var error: AudioPluginError? = nil
    private var content: Content

    var container: ModelContainer?
    var disk: URL?
    var repo: AudioRepo?
    var audioProvider: AudioProvider?

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
        guard let container = try? AudioConfigRepo.getContainer() else {
            self.error = AudioPluginError.initialization(reason: "Container 未找到")
            return
        }

        self.container = container

        let storage = Config.getStorageLocation()

        guard let storage = storage else {
            self.error = AudioPluginError.initialization(reason: "Storage 未找到")
            return
        }

        switch storage {
        case .local:
            disk = Config.localDocumentsDir?.appendingFolder(AudioPlugin.dbDirName)
        case .icloud:
            disk = Config.cloudDocumentsDir?.appendingFolder(AudioPlugin.dbDirName)
        case .custom:
            disk = Config.localDocumentsDir?.appendingFolder(AudioPlugin.dbDirName)
        }

        self.disk = try? disk!.createIfNotExist()
        self.container = try? AudioConfigRepo.getContainer()
        self.repo = try? AudioRepo(disk: disk!, reason: "onInit")
        self.audioProvider = AudioProvider(disk: disk!, db: self.repo!)
        self.audioProvider?.updateDisk(disk!)
    }

    var body: some View {
        if Self.verbose {
            os_log("\(self.t)📺 开始渲染")
        }
        
        return Group {
            if let container = self.container {
                ZStack {
                    content
                }
                .modelContainer(container)
                .environmentObject(self.audioProvider!)
                .onStorageLocationChanged(perform: handleStorageLocationChanged)
                .onDisappear(perform: handleOnDisappear)
            } else {
                Text("初始化失败")
                    .foregroundColor(.red)
            }
        }
    }
}

// MARK: - Event Handler

extension AudioRootView {
    /// 处理存储位置变化事件
    ///
    /// 当用户切换存储位置（本地/iCloud）时触发，提示用户存储位置已变化。
    func handleStorageLocationChanged() {
        if Self.verbose {
            os_log("\(self.t)📂 存储位置已变化")
        }
        
        self.m.info("存储位置发生了变化")
    }

    /// 处理视图消失事件
    ///
    /// 当视图从屏幕上消失时触发，用于清理资源。
    func handleOnDisappear() {
        if Self.verbose {
            os_log("\(self.t)👋 视图已消失")
        }
    }
}

// MARK: - Preview

#if os(macOS)
    #Preview("App - Large") {
        AppPreview()
            .frame(width: 600, height: 1000)
    }

    #Preview("App - Small") {
        AppPreview()
            .frame(width: 600, height: 600)
    }
#endif

#if os(iOS)
    #Preview("iPhone") {
        AppPreview()
    }
#endif
