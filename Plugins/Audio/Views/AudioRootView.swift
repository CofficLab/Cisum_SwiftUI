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
    
    @EnvironmentObject var man: PlayManController
    @EnvironmentObject var m: MagicMessageProvider
    @EnvironmentObject var p: PluginProvider
    @EnvironmentObject var app: AppProvider

    @State private var error: AudioPluginError? = nil
    private var content: Content
    
    /// 是否输出详细日志
    private let verbose = false

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
        if verbose {
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
                .onPlayManStateChanged(handlePlayManStateChanged)
                .onPlayManAssetChanged(handlePlayManAssetChanged)
            } else {
                Text("初始化失败")
                    .foregroundColor(.red)
            }
        }
    }
}

// MARK: - Action

extension AudioRootView {
    /// 恢复播放模式
    ///
    /// 从持久化存储中读取上次的播放模式并应用到播放器。
    /// 播放模式包括：顺序播放、单曲循环、随机播放等。
    private func restorePlayMode() {
        if verbose {
            os_log("\(self.t)🔄 恢复播放模式")
        }
        
        let mode = AudioStateRepo.getPlayMode()
        if let mode = mode {
            if verbose {
                os_log("\(self.t)✅ 播放模式: \(mode.shortName)")
            }
            self.man.setPlayMode(mode)
        }
    }

    /// 恢复上次播放状态
    ///
    /// 从持久化存储中恢复上次播放的音频、播放进度和喜欢状态。
    /// 如果没有上次播放记录，则播放第一首音频。
    ///
    /// ## 恢复流程
    /// 1. 读取上次播放的 URL 和时间
    /// 2. 如果找到，恢复该音频和进度
    /// 3. 如果没找到，播放第一首音频
    /// 4. 恢复喜欢状态
    private func restorePlaying() {
        var assetTarget: URL?
        var timeTarget: TimeInterval = 0
        var liked = false

        Task {
            if let url = AudioStateRepo.getCurrent(), let audio = await self.repo?.find(url) {
                assetTarget = audio
                liked = await self.repo?.isLiked(audio) ?? false

                if let time = AudioStateRepo.getCurrentTime() {
                    timeTarget = time
                }
                
                if verbose {
                    os_log("\(self.t)✅ 恢复播放: \(url.lastPathComponent) @ \(timeTarget)s")
                }
            } else {
                if verbose {
                    os_log("\(self.t)⚠️ 没有上次播放记录，尝试播放第一首")
                }

                if let first = try? await repo!.getFirst() {
                    assetTarget = first
                    liked = await repo!.isLiked(first)
                    
                    if verbose {
                        os_log("\(self.t)✅ 找到第一首音频")
                    }
                } else {
                    os_log("\(self.t)⚠️ 未找到任何音频")
                }
            }

            if let asset = assetTarget {
                await man.play(url: asset, autoPlay: false)
                await man.seek(time: timeTarget)
                man.setLike(liked)
            }
        }
    }

    /// 订阅播放器事件
    ///
    /// 订阅播放器的各种事件并处理，包括：
    /// - 上一首/下一首请求
    /// - 喜欢状态变化
    /// - 播放模式变化
    ///
    /// ## 事件处理
    /// - **上一首**：从数据库查找前一首音频并播放
    /// - **下一首**：从数据库查找后一首音频并播放
    /// - **喜欢状态**：更新数据库中的喜欢标记
    /// - **播放模式**：根据模式重新排序音频列表（随机/顺序）
    private func subscribe() {
        self.man.playMan.subscribe(
            name: self.className,
            onPreviousRequested: { asset in
                if verbose {
                    os_log("\(self.t)⏮️ 请求上一首")
                }

                guard let repo = self.repo else {
                    os_log("\(self.t)⚠️ AudioRepo 未找到")
                    return
                }

                Task {
                    let prev = try await repo.getPrevOf(asset, verbose: false)

                    if let prev = prev {
                        if verbose {
                            os_log("\(self.t)✅ 播放上一首: \(prev.lastPathComponent)")
                        }
                        await man.play(url: prev, autoPlay: self.man.playMan.playing)
                    }
                }
            },
            onNextRequested: { asset in
                if verbose {
                    os_log("\(self.t)⏭️ 请求下一首")
                }

                guard let repo = self.repo else {
                    os_log("\(self.t)⚠️ AudioDB 未找到")
                    return
                }

                Task {
                    let next = try await repo.getNextOf(asset, verbose: false)
                    if let next = next {
                        if verbose {
                            os_log("\(self.t)✅ 播放下一首: \(next.lastPathComponent)")
                        }
                        await man.play(url: next, autoPlay: true)
                    }
                }
            },
            onLikeStatusChanged: { url, like in
                if verbose {
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
            onPlayModeChanged: { mode in
                if verbose {
                    os_log("\(self.t)🔄 播放模式变化 -> \(mode.shortName)")
                }

                AudioStateRepo.storePlayMode(mode.rawValue)

                Task {
                    let currentURL = man.playMan.currentURL
                    switch mode {
                    case .loop:
                        if verbose {
                            os_log("\(self.t)🔁 单曲循环模式")
                        }
                    case .sequence, .repeatAll:
                        if verbose {
                            os_log("\(self.t)📋 顺序播放，重新排序")
                        }
                        await repo!.sort(currentURL, reason: self.className + ".OnPlayModeChange")
                    case .shuffle:
                        if verbose {
                            os_log("\(self.t)🔀 随机播放，打乱顺序")
                        }
                        try await repo!.sortRandom(currentURL, reason: self.className + ".OnPlayModeChange", verbose: false)
                    }
                }
            }
        )
    }
}

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
        if verbose {
            os_log("\(self.t)👀 视图已出现，开始初始化")
        }
        
        self.subscribe()
        self.restorePlaying()
        self.restorePlayMode()
        
        if verbose {
            os_log("\(self.t)✅ 初始化完成")
        }
    }

    /// 处理存储位置变化事件
    ///
    /// 当用户切换存储位置（本地/iCloud）时触发，提示用户存储位置已变化。
    func handleStorageLocationChanged() {
        if verbose {
            os_log("\(self.t)📂 存储位置已变化")
        }
        
        self.m.info("存储位置发生了变化")
    }

    /// 处理视图消失事件
    ///
    /// 当视图从屏幕上消失时触发，用于清理资源。
    func handleOnDisappear() {
        if verbose {
            os_log("\(self.t)👋 视图已消失")
        }
    }

    /// 处理播放器状态变化事件
    ///
    /// 当播放器状态改变时触发（播放/暂停/停止等）。
    /// 在暂停时会保存当前播放进度。
    ///
    /// - Parameter isPlaying: 是否正在播放
    func handlePlayManStateChanged(_ isPlaying: Bool) {
        if verbose {
            os_log("\(self.t)🎵 播放状态变化 -> \(self.man.playMan.state.stateText)")
        }
        
        if self.man.playMan.state == .paused {
            AudioStateRepo.storeCurrentTime(man.playMan.currentTime)
            
            if verbose {
                os_log("\(self.t)💾 保存播放进度: \(man.playMan.currentTime)s")
            }
        }
    }

    /// 处理播放资源变化事件
    ///
    /// 当播放器的音频资源改变时触发，保存当前播放的 URL。
    /// 如果资源在 iCloud 且未下载，会自动触发下载。
    ///
    /// - Parameter url: 新的音频资源 URL，如果为 nil 则表示停止播放
    func handlePlayManAssetChanged(_ url: URL?) {
        guard p.current?.label == AudioPlugin().label else {
            if verbose {
                os_log("\(self.t)⏭️ 跳过：当前插件不是音频插件")
            }
            return
        }

        guard let url = url else {
            if verbose {
                os_log("\(self.t)⏹️ 播放已停止")
            }
            return
        }

        if verbose {
            os_log("\(self.t)🎵 播放资源变化 -> \(url.lastPathComponent)")
        }

        Task {
            AudioStateRepo.storeCurrent(url)

            if url.isNotDownloaded {
                if verbose {
                    os_log("\(self.t)☁️ 文件未下载，开始下载")
                }
                
                do {
                    try await url.download()
                    
                    if verbose {
                        os_log("\(self.t)✅ 下载完成")
                    }
                } catch let e {
                    os_log(.error, "\(self.t)❌ 下载失败: \(e.localizedDescription)")
                }
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
