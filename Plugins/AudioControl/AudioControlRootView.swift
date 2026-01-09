import Foundation
import MagicAlert
import MagicKit
import MagicPlayMan
import OSLog
import SwiftUI
import UniformTypeIdentifiers

struct AudioControlRootView<Content>: View, SuperLog where Content: View {
    nonisolated static var emoji: String { "🎮" }
    private static var verbose: Bool { false }

    @EnvironmentObject var man: PlayManController
    @EnvironmentObject var m: MagicMessageProvider
    @EnvironmentObject var p: PluginProvider

    private var content: Content

    // 直接创建 AudioRepo 实例，避免依赖 AudioProvider
    private var audioRepo: AudioRepo? {
        guard let disk = AudioPlugin.getAudioDisk() else {
            if Self.verbose {
                os_log(.error, "\(self.t)❌ 获取音频磁盘路径失败")
            }
            return nil
        }

        do {
            return try AudioRepo(disk: disk, reason: "AudioControlPlugin")
        } catch {
            if Self.verbose {
                os_log(.error, "\(self.t)❌ 创建 AudioRepo 失败: \(error.localizedDescription)")
            }
            return nil
        }
    }

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .onAppear(perform: handleOnAppear)
    }

    /// 检查是否应该激活播放控制功能
    private var shouldActivateControl: Bool {
        p.current?.label == AudioPlugin().label
    }
}

// MARK: - Action

extension AudioControlRootView {
    /// 处理视图出现事件
    ///
    /// 当视图首次出现时触发，执行初始化操作。
    func handleOnAppear() {
        guard shouldActivateControl else {
            if Self.verbose {
                os_log("\(self.t)⏭️ 播放控制跳过：当前插件不是音频插件")
            }
            return
        }

        if Self.verbose {
            os_log("\(self.t)👀 视图已出现，开始初始化播放控制")
        }

        // 订阅播放器事件
        man.playMan.subscribe(
            name: "AudioControlPlugin",
            onPreviousRequested: { asset in
                handlePreviousRequested(asset)
            },
            onNextRequested: { asset in
                handleNextRequested(asset)
            }
        )
    }

    /// 处理上一首请求
    /// - Parameter asset: 当前播放的音频资源
    func handlePreviousRequested(_ asset: URL) {
        guard shouldActivateControl else { return }

        if Self.verbose {
            os_log("\(self.t)⏮️ 请求上一首")
        }

        guard let repo = audioRepo else {
            if Self.verbose {
                os_log("\(self.t)⚠️ AudioRepo 未初始化")
            }
            return
        }

        Task {
            let previous = try await repo.getPrevOf(asset, verbose: false)
            if let previous = previous {
                if Self.verbose {
                    os_log("\(self.t)✅ 播放上一首: \(previous.lastPathComponent)")
                }
                await man.play(url: previous, autoPlay: true)
            }
        }
    }

    /// 处理下一首请求
    /// - Parameter asset: 当前播放的音频资源
    func handleNextRequested(_ asset: URL) {
        guard shouldActivateControl else { return }

        if Self.verbose {
            os_log("\(self.t)⏭️ 请求下一首")
        }

        guard let repo = audioRepo else {
            if Self.verbose {
                os_log("\(self.t)⚠️ AudioRepo 未初始化")
            }
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
