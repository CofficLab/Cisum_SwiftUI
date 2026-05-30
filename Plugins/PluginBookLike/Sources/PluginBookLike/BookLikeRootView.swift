import Foundation
import MagicKit
import MagicPlayMan
import OSLog
import SwiftUI

public typealias BookLikeCurrentSceneProvider = @MainActor () -> String?

public struct BookLikeRootView<Content>: View, SuperLog where Content: View {
    public nonisolated static var emoji: String { BookLikePluginInfo.emoji }
    private let verbose = false

    @EnvironmentObject private var man: MagicPlayMan
    @State private var playbackSubscriptionID: UUID?

    private let content: Content
    private let targetSceneName: String
    private let currentSceneName: BookLikeCurrentSceneProvider

    public init(
        targetSceneName: String,
        currentSceneName: @escaping BookLikeCurrentSceneProvider,
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
    }

    /// 检查是否应该激活书籍喜欢管理功能
    private var shouldActivateLike: Bool {
        currentSceneName() == targetSceneName
    }
}

// MARK: - Action

private extension BookLikeRootView {
    /// 处理视图出现事件
    ///
    /// 当视图首次出现时触发，执行初始化操作。
    func handleOnAppear() {
        guard shouldActivateLike else {
            if verbose {
                os_log("\(self.t)⏭️ 书籍喜欢管理跳过：当前插件不是书籍插件")
            }
            return
        }

        if verbose {
            os_log("\(self.t)👀 视图已出现，开始初始化书籍喜欢管理")
        }

        // 订阅播放器事件，监听喜欢状态变化
        guard playbackSubscriptionID == nil else { return }

        playbackSubscriptionID = man.subscribe(
            name: "BookLikePlugin",
            onLikeStatusChanged: { url, liked in
                handleLikeStatusChanged(url: url, liked: liked)
            }
        )
    }

    func handleOnDisappear() {
        guard let playbackSubscriptionID else { return }

        man.unsubscribe(playbackSubscriptionID)
        self.playbackSubscriptionID = nil
    }

    /// 处理喜欢状态变化事件
    ///
    /// 当用户点击喜欢/取消喜欢按钮时触发，更新独立的数据表。
    ///
    /// - Parameters:
    ///   - url: 书籍URL
    ///   - liked: 是否喜欢
    func handleLikeStatusChanged(url: URL, liked: Bool) {
        guard shouldActivateLike else { return }

        if verbose {
            os_log("\(self.t)❤️ 书籍喜欢状态变化: \(url.lastPathComponent) -> \(liked ? "喜欢" : "取消喜欢")")
        }

        Task {
            // 这里可以实现书籍喜欢状态的管理
            // 由于书籍喜欢功能相对简单，可以直接使用 UserDefaults 或简单的状态管理
            // 暂时记录日志，实际实现可以扩展为独立的书籍喜欢数据模型

            if liked {
                if verbose {
                    os_log("\(self.t)👍 书籍已标记为喜欢: \(url.lastPathComponent)")
                }
            } else {
                if verbose {
                    os_log("\(self.t)😔 书籍已取消喜欢: \(url.lastPathComponent)")
                }
            }

            // 发送通知，通知其他组件喜欢状态已更新
            NotificationCenter.default.post(
                name: .BookLikeStatusChanged,
                object: nil,
                userInfo: [
                    "url": url,
                    "liked": liked
                ]
            )
        }
    }
}

// MARK: - Notification Names

public extension Notification.Name {
    /// 书籍喜欢状态变化通知
    static let BookLikeStatusChanged = Notification.Name("BookLikeStatusChanged")
}
