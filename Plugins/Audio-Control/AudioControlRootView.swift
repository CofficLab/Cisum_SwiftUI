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

    @EnvironmentObject var man: PlayMan
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
            .onDBDeleted(perform: handleDBDeleted)
            .onStorageLocationDidReset(perform: handleStorageLocationDidReset)
    }

    /// 检查是否应该激活播放控制功能
    private var shouldActivateControl: Bool {
        p.currentSceneName == "音乐库"
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
        man.subscribe(
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
                await man.play(previous, autoPlay: true)
            }
        }
    }

    /// 处理下一首请求
    /// - Parameter asset: 当前播放的音频资源
    func handleNextRequested(_ asset: URL) {
        guard shouldActivateControl else { return }

        if Self.verbose {
            os_log("\(self.t)⏭️ 请求下一首")
            os_log("\(self.t)📍 当前播放: \(asset.lastPathComponent)")
        }

        guard let repo = audioRepo else {
            if Self.verbose {
                os_log("\(self.t)⚠️ AudioRepo 未初始化")
            }
            return
        }

        Task {
            do {
                let next = try await repo.getNextOf(asset, verbose: Self.verbose)
                if let next = next {
                    if Self.verbose {
                        os_log("\(self.t)✅ 找到下一首: \(next.lastPathComponent)")
                        os_log("\(self.t)▶️ 开始播放下一首")
                    }
                    await man.play(next, autoPlay: true)
                } else {
                    // 没有下一首的情况
                    if Self.verbose {
                        os_log("\(self.t)⚠️ 没有找到下一首")

                        // 获取总文件数用于调试
                        let allUrls = await repo.getAll(reason: "调试")
                        os_log("\(self.t)📊 仓库中共有 \(allUrls.count) 个文件")
                    }

                    // 停止播放
                    await man.stop()

                    // 显示提示
                    await MainActor.run {
                        m.info("已是最后一首，没有更多文件")
                    }
                }
            } catch {
                if Self.verbose {
                    os_log("\(self.t)❌ 获取下一首失败: \(error.localizedDescription)")
                }
            }
        }
    }

    /// 处理存储位置重置事件
    ///
    /// 当存储位置被重置时，停止当前播放。
    func handleStorageLocationDidReset() {
        guard shouldActivateControl else { return }

        if Self.verbose {
            os_log("\(self.t)🛑 存储位置重置，停止播放")
        }

        Task {
            // 停止播放
            await man.stop()

            // 显示提示信息
            await MainActor.run {
                m.info("存储位置已重置，已停止播放")
            }
        }
    }

    /// 处理音频删除事件
    ///
    /// 当音频文件被删除时，检查是否是正在播放的文件。
    /// 如果是，则自动播放第一首。
    /// - Parameter notification: 删除完成的通知
    func handleDBDeleted(_ notification: Notification) {
        guard shouldActivateControl else { return }

        guard let urlsToDelete = notification.userInfo?["urls"] as? [URL],
              let currentAsset = man.asset else {
            return
        }

        // 检查正在播放的文件是否在被删除列表中
        if urlsToDelete.contains(currentAsset) {
            if Self.verbose {
                os_log("\(self.t)⚠️ 正在播放的文件（\(currentAsset.lastPathComponent)）被删除，自动播放第一首")
            }

            guard let repo = audioRepo else {
                if Self.verbose {
                    os_log("\(self.t)⚠️ AudioRepo 未初始化")
                }
                return
            }

            Task {
                do {
                    // 获取第一首文件
                    let firstUrl = try await repo.getFirst()

                    if let first = firstUrl {
                        if Self.verbose {
                            os_log("\(self.t)✅ 播放第一首: \(first.lastPathComponent)")
                        }

                        // 显示提示信息
                        await MainActor.run {
                            m.warning("正在播放的文件已被删除，自动播放第一首")
                        }

                        // 播放第一首
                        await man.play(first, autoPlay: true)
                    } else {
                        if Self.verbose {
                            os_log("\(self.t)⚠️ 仓库中没有文件")
                        }

                        // 仓库为空，停止播放
                        await man.stop()

                        await MainActor.run {
                            m.info("仓库中没有文件")
                        }
                    }
                } catch {
                    if Self.verbose {
                        os_log("\(self.t)❌ 获取第一首失败: \(error.localizedDescription)")
                    }

                    // 获取失败，停止播放
                    await man.stop()

                    await MainActor.run {
                        m.error("无法播放下一首: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}
