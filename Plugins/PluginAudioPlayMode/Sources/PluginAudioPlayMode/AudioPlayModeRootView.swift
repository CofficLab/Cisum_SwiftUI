import Foundation
import MagicAlert
import MagicKit
import MagicPlayMan
import OSLog
import SwiftUI

public typealias AudioPlayModeCurrentSceneProvider = @MainActor () -> String?
public typealias AudioPlayModeSortAction = @MainActor (_ currentURL: URL?) async throws -> Void
public typealias AudioPlayModeShuffleAction = @MainActor (_ currentURL: URL?) async throws -> Void

enum AudioPlayModeQueueUpdatePolicy {
    static func shouldApplyQueueUpdate(requestedModeRawValue: String, currentMode: MagicPlayMode) -> Bool {
        currentMode.rawValue == requestedModeRawValue
    }

    static func shouldRestorePlayMode(isActiveScene: Bool, storedMode: MagicPlayMode, currentMode: MagicPlayMode) -> Bool {
        isActiveScene && storedMode != currentMode
    }
}

public struct AudioPlayModeRootView<Content>: View, SuperLog where Content: View {
    public nonisolated static var emoji: String { AudioPlayModePluginInfo.emoji }
    private let verbose = false

    @EnvironmentObject private var man: MagicPlayMan
    @State private var playbackSubscriptionID: UUID?

    private let content: Content
    private let targetSceneName: String
    private let currentSceneName: AudioPlayModeCurrentSceneProvider
    private let sort: AudioPlayModeSortAction
    private let shuffle: AudioPlayModeShuffleAction

    public init(
        targetSceneName: String,
        currentSceneName: @escaping AudioPlayModeCurrentSceneProvider,
        sort: @escaping AudioPlayModeSortAction,
        shuffle: @escaping AudioPlayModeShuffleAction,
        @ViewBuilder content: () -> Content
    ) {
        self.targetSceneName = targetSceneName
        self.currentSceneName = currentSceneName
        self.sort = sort
        self.shuffle = shuffle
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

    private var shouldActivatePlayMode: Bool {
        currentSceneName() == targetSceneName
    }
}

private extension AudioPlayModeRootView {
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
                os_log("\(self.t)⏭️ 播放模式管理跳过：当前插件不是音频插件")
            }
            return
        }

        if verbose {
            os_log("\(self.t)👀 视图已出现，开始初始化播放模式管理")
        }

        restoreStoredPlayMode()

        guard playbackSubscriptionID == nil else { return }

        playbackSubscriptionID = man.subscribe(
            name: "AudioPlayModePlugin",
            onPlayModeChanged: { mode in
                handlePlayModeChanged(mode)
            }
        )
    }

    func restoreStoredPlayMode() {
        Task { @MainActor in
            let storedMode = await AudioPlayModeStore.shared.getPlayMode()
            guard AudioPlayModeQueueUpdatePolicy.shouldRestorePlayMode(
                isActiveScene: shouldActivatePlayMode,
                storedMode: storedMode,
                currentMode: man.playMode
            ) else {
                return
            }

            man.restorePlayMode(storedMode)
        }
    }

    func handleOnDisappear() {
        deactivatePlayMode()
    }

    private func deactivatePlayMode() {
        guard let playbackSubscriptionID else { return }

        man.unsubscribe(playbackSubscriptionID)
        self.playbackSubscriptionID = nil
    }

    func handlePlayModeChanged(_ mode: MagicPlayMode) {
        guard shouldActivatePlayMode else { return }

        let modeRawValue = mode.rawValue
        let modeShortName = mode.shortName
        let currentURL = man.currentURL

        if verbose {
            os_log("\(self.t)🔄 播放模式变化 -> \(modeShortName)")
        }

        Task { [modeRawValue, modeShortName] in
            await AudioPlayModeStore.shared.storePlayModeRawValue(modeRawValue, shortName: modeShortName)
        }

        Task { @MainActor [currentURL, modeRawValue, sort, shuffle] in
            guard AudioPlayModeQueueUpdatePolicy.shouldApplyQueueUpdate(
                requestedModeRawValue: modeRawValue,
                currentMode: man.playMode
            ) else {
                return
            }

            guard let mode = MagicPlayMode(rawValue: modeRawValue) else {
                return
            }

            do {
                switch mode {
                case .loop:
                    if verbose {
                        os_log("\(Self.t)🔁 单曲循环模式")
                    }
                    alert_info(String(localized: "Repeat One", table: "Audio-PlayMode", bundle: .module))
                case .sequence, .repeatAll:
                    if verbose {
                        os_log("\(Self.t)📋 顺序播放，重新排序")
                    }
                    alert_info(String(localized: "Sequential Play", table: "Audio-PlayMode", bundle: .module))
                    try await sort(currentURL)
                case .shuffle:
                    if verbose {
                        os_log("\(Self.t)🔀 随机播放，打乱顺序")
                    }
                    alert_info(String(localized: "Shuffle", table: "Audio-PlayMode", bundle: .module))
                    try await shuffle(currentURL)
                }
            } catch {
                if verbose {
                    os_log("\(Self.t)⚠️ 播放模式重排失败: \(error.localizedDescription)")
                }
                alert_error(String(localized: "Cannot update play queue: \(error.localizedDescription)", table: "Audio-PlayMode", bundle: .module))
            }
        }
    }
}

public extension Notification.Name {
    static let AudioPlayModeChanged = Notification.Name("AudioPlayModeChanged")
}
