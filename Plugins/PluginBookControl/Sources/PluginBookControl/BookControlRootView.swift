import Foundation
import MagicKit
import MagicPlayMan
import OSLog
import SwiftUI

public typealias BookControlCurrentSceneProvider = @MainActor () -> String?

public struct BookControlRootView<Content>: View, SuperLog where Content: View {
    public nonisolated static var emoji: String { BookControlPluginInfo.emoji }
    private let verbose = false

    @EnvironmentObject private var man: MagicPlayMan

    private let content: Content
    private let targetSceneName: String
    private let currentSceneName: BookControlCurrentSceneProvider

    public init(
        targetSceneName: String,
        currentSceneName: @escaping BookControlCurrentSceneProvider,
        @ViewBuilder content: () -> Content
    ) {
        self.targetSceneName = targetSceneName
        self.currentSceneName = currentSceneName
        self.content = content()
    }

    public var body: some View {
        content
            .onAppear(perform: handleOnAppear)
    }

    /// 检查是否应该激活书籍播放控制功能
    private var shouldActivateControl: Bool {
        currentSceneName() == targetSceneName
    }
}

// MARK: - Action

private extension BookControlRootView {
    /// 处理视图出现事件
    ///
    /// 当视图首次出现时触发，执行初始化操作。
    func handleOnAppear() {
        guard shouldActivateControl else {
            if verbose {
                os_log("\(self.t)⏭️ 书籍播放控制跳过：当前场景不是书籍场景")
            }
            return
        }

        if verbose {
            os_log("\(self.t)👀 视图已出现，开始初始化书籍播放控制")
        }

        // 订阅播放器事件
        man.subscribe(
            name: "BookControlPlugin",
            onPreviousRequested: { asset in
                handlePreviousRequested(asset)
            },
            onNextRequested: { asset in
                handleNextRequested(asset)
            }
        )
    }

    /// 处理上一章请求
    /// - Parameter asset: 当前播放的书籍章节资源
    func handlePreviousRequested(_ asset: URL) {
        guard shouldActivateControl else { return }

        if verbose {
            os_log("\(self.t)⏮️ 请求上一章")
        }

        if let prev = asset.getPrevFile() {
            Task {
                await man.play(prev, reason: "handlePreviousRequested")
                if verbose {
                    os_log("\(self.t)✅ 播放上一章: \(prev.lastPathComponent)")
                }
            }
        } else {
            if verbose {
                os_log("\(self.t)⚠️ 没有上一章")
            }
        }
    }

    /// 处理下一章请求
    /// - Parameter asset: 当前播放的书籍章节资源
    func handleNextRequested(_ asset: URL) {
        guard shouldActivateControl else { return }

        if verbose {
            os_log("\(self.t)⏭️ 请求下一章")
        }

        if let next = asset.getNextFile() {
            Task {
                await man.play(next, reason: "handleNextRequested")
                if verbose {
                    os_log("\(self.t)✅ 播放下一章: \(next.lastPathComponent)")
                }
            }
        } else {
            if verbose {
                os_log("\(self.t)⚠️ 没有下一章")
            }
        }
    }
}
