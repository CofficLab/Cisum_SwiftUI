import Foundation
import CisumUIComponents
import MagicPlayMan
import OSLog
import ProviderScene
import SwiftUI

enum AudioLikeStatusChangePolicy {
    static func shouldAcceptChange(isSceneActive: Bool) -> Bool {
        isSceneActive
    }

    static func shouldReportSaveFailure(isSceneActive: Bool) -> Bool {
        isSceneActive
    }
}

public struct AudioLikeRootView<Content>: View, SuperLog where Content: View {
    public nonisolated static var emoji: String { AudioLikePluginInfo.emoji }
    private let verbose = false

    @EnvironmentObject private var man: MagicPlayMan
    @State private var playbackSubscriptionID: UUID?

    private let content: Content
    private let targetSceneName: String
    private let scene: (any SceneProviding)?

    public init(
        targetSceneName: String,
        scene: (any SceneProviding)?,
        @ViewBuilder content: () -> Content
    ) {
        self.targetSceneName = targetSceneName
        self.scene = scene
        self.content = content()
    }

    public var body: some View {
        content
            .onAppear(perform: handleOnAppear)
            .onDisappear(perform: handleOnDisappear)
            .onChange(of: scene?.currentSceneName) { _, newSceneName in
                handleCurrentSceneChanged(newSceneName)
            }
    }

    private var shouldActivateLike: Bool {
        scene?.currentSceneName == targetSceneName
    }
}

private extension AudioLikeRootView {
    func handleOnAppear() {
        updateLikeActivation(for: scene?.currentSceneName)
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
        deactivateLike()
    }

    private func deactivateLike() {
        guard let playbackSubscriptionID else { return }

        man.unsubscribe(playbackSubscriptionID)
        self.playbackSubscriptionID = nil
    }

    func handleLikeStatusChanged(url: URL, liked: Bool) {
        guard AudioLikeStatusChangePolicy.shouldAcceptChange(isSceneActive: shouldActivateLike) else { return }

        Task { @MainActor in
            let audioId = url.absoluteString

            do {
                try await AudioLikeRepo.shared.updateLikeStatus(
                    audioId: audioId,
                    liked: liked,
                    url: url,
                    title: url.lastPathComponent
                )

                if verbose {
                    os_log("\(self.t)💾 保存喜欢状态: \(url.lastPathComponent) -> \(liked ? "喜欢" : "取消喜欢")")
                }

                NotificationCenter.postAudioLikeStatusChanged(audioId: audioId, url: url, liked: liked)
            } catch {
                guard AudioLikeStatusChangePolicy.shouldReportSaveFailure(isSceneActive: shouldActivateLike) else {
                    return
                }
                os_log(.error, "\(self.t)❌ 保存喜欢状态失败: \(error.localizedDescription)")
                alert_error(String(localized: "Failed to save like status: \(error.localizedDescription)", bundle: .module))
            }
        }
    }
}

public extension Notification.Name {
    static let AudioLikeStatusChanged = Notification.Name("AudioLikeStatusChanged")
}

public extension NotificationCenter {
    static func postAudioLikeStatusChanged(audioId: String, url: URL, liked: Bool) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: .AudioLikeStatusChanged,
                object: nil,
                userInfo: [
                    "audioId": audioId,
                    "url": url,
                    "liked": liked,
                ]
            )
        }
    }
}
