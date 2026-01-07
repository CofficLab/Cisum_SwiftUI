import Foundation
import MagicAlert
import MagicCore
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
                .onAppear(perform: handleOnAppear)
                .onStorageLocationChanged(perform: handleStorageLocationChanged)
                .onDisappear(perform: handleOnDisappear)
            } else {
                Text("初始化失败")
                    .foregroundColor(.red)
            }
        }
    }
}

// MARK: - Action


// MARK: - Event Handler

extension AudioRootView {
    /// 处理视图出现事件
    ///
    /// 当视图首次出现时触发，执行初始化操作。
    ///
    /// ## 初始化流程
    /// 1. 订阅播放器事件
    /// 2. 恢复上次播放状态
    /// 3. 恢复播放模式
    func handleOnAppear() {
        guard p.current?.label == AudioPlugin().label else {
            if Self.verbose {
                os_log("\(self.t)⏭️ 跳过：当前插件不是音频插件")
            }
            return
        }

        if Self.verbose {
            os_log("\(self.t)👀 视图已出现，开始初始化")
        }

        // 调用 subscribe 方法
        self.man.playMan.subscribe(
            name: self.className,
            onPreviousRequested: { asset in
                if Self.verbose {
                    os_log("\(self.t)⏮️ 请求上一首")
                }

                guard let repo = self.repo else {
                    os_log("\(self.t)⚠️ AudioDB 未找到")
                    return
                }

                Task {
                    let previous = try await repo.getPrevOf(asset, verbose: false)
                    if let previous = previous {
                        if Self.verbose {
                            os_log("\(self.t)✅ 播放上一首: \(previous.lastPathComponent)")
                        }
                        await self.man.play(url: previous, autoPlay: true)
                    }
                }
            },
            onNextRequested: { asset in
                self.handleNextRequested(asset)
            },
            onLikeStatusChanged: { url, like in
                if Self.verbose {
                    os_log("\(self.t)❤️ 喜欢状态变化 -> \(like ? "喜欢" : "取消喜欢")")
                }

                guard let repo = self.repo else {
                    os_log("\(self.t)⚠️ AudioDB 未找到")
                    return
                }
                Task {
                    await repo.like(url, liked: like)
                }
            },
            onPlayModeChanged: { (mode: PlayMode) in
                // 播放模式处理已移至 AudioPlayModePlugin
                // 发送通知让播放模式插件处理
                NotificationCenter.default.post(
                    name: .AudioPlayModeChanged,
                    object: nil,
                    userInfo: ["mode": mode]
                )
            }
        )

        if Self.verbose {
            os_log("\(self.t)✅ 初始化完成")
        }
    }

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

    /// 处理下一首请求事件
    ///
    /// 当用户请求播放下一首音频时触发。
    /// 从数据库中查找当前音频的后一首音频并播放。
    ///
    /// - Parameter asset: 当前播放的音频资源
    func handleNextRequested(_ asset: URL) {
        guard p.current?.label == AudioPlugin().label else {
            if Self.verbose {
                os_log("\(self.t)⏭️ 请求下一首被跳过：当前插件不是音频插件")
            }
            return
        }

        if Self.verbose {
            os_log("\(self.t)⏭️ 请求下一首")
        }

        guard let repo = self.repo else {
            os_log("\(self.t)⚠️ AudioDB 未找到")
            return
        }

        Task {
            let next = try await repo.getNextOf(asset, verbose: false)
            if let next = next {
                if Self.verbose {
                    os_log("\(self.t)✅ 播放下一首: \(next.lastPathComponent)")
                }
                await man.play(url: next, autoPlay: true)
            }
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
