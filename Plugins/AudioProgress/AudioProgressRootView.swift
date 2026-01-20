import Foundation
import MagicAlert
import MagicKit
import MagicPlayMan
import OSLog
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct AudioProgressRootView<Content>: View, SuperLog where Content: View {
    nonisolated static var emoji: String { "💾" }
    private static var verbose: Bool { false }

    @EnvironmentObject var man: PlayMan
    @EnvironmentObject var m: MagicMessageProvider
    @EnvironmentObject var p: PluginProvider

    private var content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .onAppear(perform: handleOnAppear)
            .onPlayManStateChanged(handlePlayManStateChanged)
            .onPlayManAssetChanged(handlePlayManAssetChanged)
    }

    /// 检查是否应该激活进度管理功能
    private var shouldActivateProgress: Bool {
        p.current?.label == AudioPlugin().label
    }
}

// MARK: - Action

extension AudioProgressRootView {
    /// 恢复播放模式
    ///
    /// 从持久化存储中读取上次的播放模式并应用到播放器。
    /// 播放模式包括：顺序播放、单曲循环、随机播放等。

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
            if let url = AudioStateRepo.getCurrent() {
                assetTarget = url
                liked = await AudioLikeRepo.shared.isLiked(url: url)

                if let time = AudioStateRepo.getCurrentTime() {
                    timeTarget = time
                }

                if Self.verbose {
                    os_log("\(self.t)✅ 恢复播放: \(url.lastPathComponent) @ \(timeTarget)s")
                }
            } else {
                if Self.verbose {
                    os_log("\(self.t)⚠️ 没有上次播放记录")
                }
            }

            if let asset = assetTarget {
                await man.play(asset, autoPlay: false)
                man.seek(time: timeTarget)
                man.setLike(liked)
            }
        }
    }
}

// MARK: - Event Handler

extension AudioProgressRootView {
    /// 处理视图出现事件
    ///
    /// 当视图首次出现时触发，执行初始化操作。
    ///
    /// ## 初始化流程
    /// 1. 恢复上次播放状态
    /// 2. 恢复播放模式
    func handleOnAppear() {
        guard shouldActivateProgress else {
            if Self.verbose {
                os_log("\(self.t)⏭️ 进度管理跳过：当前插件不是音频插件")
            }
            return
        }

        self.restorePlaying()
    }


    /// 处理播放器状态变化事件
    ///
    /// 当播放器状态改变时触发（播放/暂停/停止等）。
    /// 在暂停时会保存当前播放进度。
    ///
    /// - Parameter isPlaying: 是否正在播放
    func handlePlayManStateChanged(_ isPlaying: Bool) {
        guard shouldActivateProgress else { return }

        if self.man.state == .paused {
            AudioStateRepo.storeCurrentTime(man.currentTime)

            if Self.verbose {
                os_log("\(self.t)💾 保存播放进度: \(man.currentTime)s")
            }
        }
    }

    /// 处理播放资源变化事件
    ///
    /// 当播放器的音频资源改变时触发，保存当前播放的 URL。
    ///
    /// - Parameter url: 新的音频资源 URL，如果为 nil 则表示停止播放
    func handlePlayManAssetChanged(_ url: URL?) {
        guard shouldActivateProgress else { return }

        guard let url = url else {
            if Self.verbose {
                os_log("\(self.t)⏹️ 播放已停止")
            }
            return
        }

        Task {
            AudioStateRepo.storeCurrent(url)
        }
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
