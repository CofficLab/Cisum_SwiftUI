import Foundation
import MagicKit
import MagicPlayMan
import OSLog
import SwiftUI

public typealias BookPlayModeCurrentSceneProvider = @MainActor () -> String?

public struct BookPlayModeRootView<Content>: View, SuperLog where Content: View {
    public nonisolated static var emoji: String { BookPlayModePluginInfo.emoji }
    private let verbose = false

    @EnvironmentObject private var man: MagicPlayMan
    @State private var playbackSubscriptionID: UUID?

    private let content: Content
    private let targetSceneName: String
    private let currentSceneName: BookPlayModeCurrentSceneProvider

    public init(
        targetSceneName: String,
        currentSceneName: @escaping BookPlayModeCurrentSceneProvider,
        @ViewBuilder content: () -> Content
    ) {
        self.targetSceneName = targetSceneName
        self.currentSceneName = currentSceneName
        self.content = content()
    }

    public var body: some View {
        content
            .onAppear(perform: handleOnAppear)
            .onDisappear(perform: handleOnDisappear)
            .onChange(of: currentSceneName()) { _, newSceneName in
                handleCurrentSceneChanged(newSceneName)
            }
    }

    /// 检查是否应该激活书籍播放模式管理功能
    private var shouldActivatePlayMode: Bool {
        currentSceneName() == targetSceneName
    }
}

// MARK: - Action

private extension BookPlayModeRootView {
    /// 处理视图出现事件
    ///
    /// 当视图首次出现时触发，执行初始化操作。
    func handleOnAppear() {
        updatePlayModeActivation(for: currentSceneName())
    }

    func handleCurrentSceneChanged(_ sceneName: String?) {
        updatePlayModeActivation(for: sceneName)
    }

    private func updatePlayModeActivation(for sceneName: String?) {
        if sceneName == targetSceneName {
            activatePlayMode()
        } else {
            deactivatePlayMode()
        }
    }

    private func activatePlayMode() {
        guard shouldActivatePlayMode else {
            if verbose {
                os_log("\(self.t)⏭️ 书籍播放模式管理跳过：当前场景不是书籍场景")
            }
            return
        }

        if verbose {
            os_log("\(self.t)👀 视图已出现，开始初始化书籍播放模式管理")
        }

        // 订阅播放器事件，监听播放模式变化
        guard playbackSubscriptionID == nil else { return }

        playbackSubscriptionID = man.subscribe(
            name: "BookPlayModePlugin",
            onPlayModeChanged: { mode in
                handlePlayModeChanged(mode)
            }
        )
    }

    func handleOnDisappear() {
        deactivatePlayMode()
    }

    private func deactivatePlayMode() {
        guard let playbackSubscriptionID else { return }

        man.unsubscribe(playbackSubscriptionID)
        self.playbackSubscriptionID = nil
    }

    /// 处理播放模式变化事件
    ///
    /// 当播放模式改变时触发，根据新模式处理书籍播放逻辑。
    ///
    /// - Parameter mode: 新的播放模式
    func handlePlayModeChanged(_ mode: MagicPlayMode) {
        guard shouldActivatePlayMode else { return }

        if verbose {
            os_log("\(self.t)🔄 书籍播放模式变化 -> \(mode.shortName)")
        }

        // 对于书籍播放，播放模式主要影响章节间的切换逻辑
        switch mode {
        case .loop:
            if verbose {
                os_log("\(self.t)🔁 单曲循环模式 - 书籍将重复播放当前章节")
            }
            // 单曲循环：重复播放当前章节

        case .sequence, .repeatAll:
            if verbose {
                os_log("\(self.t)📋 顺序播放模式 - 书籍将按章节顺序播放")
            }
            // 顺序播放：按章节顺序播放

        case .shuffle:
            if verbose {
                os_log("\(self.t)🔀 随机播放模式 - 书籍章节将随机播放")
            }
            // 随机播放：章节随机播放
        }

        // 这里可以实现具体的书籍播放模式逻辑
        // 比如重新组织书籍的播放队列等
        if verbose {
            os_log("\(self.t)⚠️ 书籍播放模式逻辑待实现")
        }
    }
}
