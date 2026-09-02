import Foundation
import CisumUIComponents
import MagicPlayMan
import OSLog
import SwiftUI

public typealias BookPlayModeCurrentSceneProvider = @MainActor () -> String?

enum BookPlayModeRestorePolicy {
    static func shouldStorePlayModeChange(currentGeneration: Int, requestGeneration: Int) -> Bool {
        currentGeneration == requestGeneration
    }

    static func generationAfterDeactivation(_ generation: Int) -> Int {
        generation + 1
    }

    static func shouldRestorePlayMode(
        currentGeneration: Int,
        requestGeneration: Int,
        isActiveScene: Bool,
        storedMode: MagicPlayMode,
        currentMode: MagicPlayMode
    ) -> Bool {
        currentGeneration == requestGeneration && isActiveScene && storedMode != currentMode
    }
}

public struct BookPlayModeRootView<Content>: View, SuperLog where Content: View {
    public nonisolated static var emoji: String { BookPlayModePluginInfo.emoji }
    private let verbose = false

    @EnvironmentObject private var man: MagicPlayMan
    @State private var playbackSubscriptionID: UUID?
    @State private var playModeChangeGeneration: Int = 0

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
                os_log("\(self.t)⏭️ Skipping audiobook play mode management: current scene is not Books")
            }
            return
        }

        if verbose {
            os_log("\(self.t)👀 View appeared, initializing audiobook play mode management")
        }

        restoreStoredPlayMode()

        // 订阅播放器事件，监听播放模式变化
        guard playbackSubscriptionID == nil else { return }

        playbackSubscriptionID = man.subscribe(
            name: "BookPlayModePlugin",
            onPlayModeChanged: { mode in
                handlePlayModeChanged(mode)
            }
        )
    }

    func restoreStoredPlayMode() {
        let generation = playModeChangeGeneration

        Task { @MainActor in
            let storedMode = await BookPlayModeStore.shared.getPlayMode()
            guard BookPlayModeRestorePolicy.shouldRestorePlayMode(
                currentGeneration: playModeChangeGeneration,
                requestGeneration: generation,
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
        playModeChangeGeneration = BookPlayModeRestorePolicy.generationAfterDeactivation(playModeChangeGeneration)

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
        playModeChangeGeneration += 1
        let generation = playModeChangeGeneration

        if verbose {
            os_log("\(self.t)🔄 Audiobook play mode changed -> \(mode.shortName)")
        }

        Task { @MainActor [mode, generation] in
            guard BookPlayModeRestorePolicy.shouldStorePlayModeChange(
                currentGeneration: playModeChangeGeneration,
                requestGeneration: generation
            ) else {
                return
            }

            await BookPlayModeStore.shared.storePlayMode(mode)
        }

        // 对于书籍播放，播放模式主要影响章节间的切换逻辑
        switch mode {
        case .loop:
            if verbose {
                os_log("\(self.t)🔁 Repeat one mode - audiobook will repeat the current chapter")
            }
            alert_info(String(localized: "Repeat One", bundle: .module))

        case .sequence, .repeatAll:
            if verbose {
                os_log("\(self.t)📋 Sequential play mode - audiobook will follow chapter order")
            }
            alert_info(String(localized: "Sequential Play", bundle: .module))

        case .shuffle:
            if verbose {
                os_log("\(self.t)🔀 Shuffle mode - audiobook chapters will play randomly")
            }
            alert_info(String(localized: "Shuffle", bundle: .module))
        }
    }
}
