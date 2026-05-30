import Foundation
import MagicAlert
import MagicKit
import MagicPlayMan
import OSLog
import SwiftUI

public typealias AudioLikeCurrentSceneProvider = @MainActor () -> String?

public struct AudioLikeRootView<Content>: View, SuperLog where Content: View {
    public nonisolated static var emoji: String { AudioLikePluginInfo.emoji }
    private let verbose = false

    @EnvironmentObject private var man: MagicPlayMan
    @State private var playbackSubscriptionID: UUID?

    private let content: Content
    private let targetSceneName: String
    private let currentSceneName: AudioLikeCurrentSceneProvider

    public init(
        targetSceneName: String,
        currentSceneName: @escaping AudioLikeCurrentSceneProvider,
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

    private var shouldActivateLike: Bool {
        currentSceneName() == targetSceneName
    }
}

private extension AudioLikeRootView {
    func handleOnAppear() {
        guard shouldActivateLike else {
            if verbose {
                os_log("\(self.t)⏭️ 喜欢管理跳过：当前插件不是音频插件")
            }
            return
        }

        if verbose {
            os_log("\(self.t)👀 视图已出现，开始初始化喜欢管理")
        }

        guard playbackSubscriptionID == nil else { return }

        playbackSubscriptionID = man.subscribe(
            name: "AudioLikePlugin",
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

    func handleLikeStatusChanged(url: URL, liked: Bool) {
        guard shouldActivateLike else { return }

        Task {
            let audioId = url.absoluteString

            do {
                if let existingModel = try await AudioLikeRepo.shared.findLikeModel(audioId: audioId) {
                    existingModel.liked = liked
                    existingModel.updatedAt = Date()
                    try await AudioLikeRepo.shared.save(existingModel)
                } else {
                    let newModel = AudioLikeModel(
                        audioId: audioId,
                        url: url,
                        title: url.lastPathComponent,
                        liked: liked
                    )
                    try await AudioLikeRepo.shared.save(newModel)
                }

                if verbose {
                    os_log("\(self.t)💾 保存喜欢状态: \(url.lastPathComponent) -> \(liked ? "喜欢" : "取消喜欢")")
                }

                NotificationCenter.default.post(
                    name: .AudioLikeStatusChanged,
                    object: nil,
                    userInfo: [
                        "audioId": audioId,
                        "url": url,
                        "liked": liked,
                    ]
                )
            } catch {
                os_log(.error, "\(self.t)❌ 保存喜欢状态失败: \(error.localizedDescription)")
                alert_error(String(localized: "Failed to save like status: \(error.localizedDescription)", table: "Audio-Like", bundle: .module))
            }
        }
    }
}

public extension Notification.Name {
    static let AudioLikeStatusChanged = Notification.Name("AudioLikeStatusChanged")
}
