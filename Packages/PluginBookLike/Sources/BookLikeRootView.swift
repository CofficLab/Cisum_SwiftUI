import Foundation
import CisumUIComponents
import MagicPlayMan
import OSLog
import SwiftUI

public typealias BookLikeCurrentSceneProvider = @MainActor () -> String?

enum BookLikeStatusChangePolicy {
    static func shouldAcceptChange(isSceneActive: Bool) -> Bool {
        isSceneActive
    }
}

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
            .onChange(of: currentSceneName()) { _, newSceneName in
                handleCurrentSceneChanged(newSceneName)
            }
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
        updateLikeActivation(for: currentSceneName())
    }

    func handleCurrentSceneChanged(_ sceneName: String?) {
        updateLikeActivation(for: sceneName)
    }

    private func updateLikeActivation(for sceneName: String?) {
        if sceneName == targetSceneName {
            activateLike()
        } else {
            deactivateLike()
        }
    }

    private func activateLike() {
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
        deactivateLike()
    }

    private func deactivateLike() {
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
        guard BookLikeStatusChangePolicy.shouldAcceptChange(isSceneActive: shouldActivateLike) else { return }

        if verbose {
            os_log("\(self.t)❤️ 书籍喜欢状态变化: \(url.lastPathComponent) -> \(liked ? "喜欢" : "取消喜欢")")
        }

        Task { @MainActor in
            BookLikeStore.setLiked(liked, url: url)

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
            NotificationCenter.postBookLikeStatusChanged(url: url, liked: liked)
        }
    }
}

// MARK: - Notification Names

public extension Notification.Name {
    /// 书籍喜欢状态变化通知
    static let BookLikeStatusChanged = Notification.Name("BookLikeStatusChanged")
}

public extension NotificationCenter {
    static func postBookLikeStatusChanged(url: URL, liked: Bool) {
        DispatchQueue.main.async {
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
