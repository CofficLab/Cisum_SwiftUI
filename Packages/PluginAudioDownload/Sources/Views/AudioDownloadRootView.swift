import CisumUIComponents
import MagicPlayMan
import OSLog
import ProviderScene
import SwiftUI

enum AudioDownloadRequestPolicy {
    static func shouldStartDownload(
        isSceneActive: Bool,
        asset: URL?,
        isNotDownloaded: Bool,
        activeDownloads: [URL] = []
    ) -> Bool {
        guard isSceneActive, let asset, isNotDownloaded else {
            return false
        }

        return !activeDownloads.contains { representsSameFile($0, asset) }
    }

    static func shouldCheckCurrentAsset(isSceneActive: Bool, asset: URL?) -> Bool {
        isSceneActive && asset != nil
    }

    static func shouldApplyDownloadResult(
        requestedAsset: URL,
        currentAsset: URL?,
        isSceneActive: Bool,
        currentGeneration: Int = 0,
        requestGeneration: Int = 0
    ) -> Bool {
        currentGeneration == requestGeneration
            && isSceneActive
            && representsSameFile(requestedAsset, currentAsset)
    }

    static func generationAfterDeactivation(_ generation: Int) -> Int {
        generation + 1
    }

    private static func representsSameFile(_ lhs: URL?, _ rhs: URL?) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none):
            return true
        case let (.some(lhs), .some(rhs)):
            return lhs.isSameFileLocation(as: rhs)
        default:
            return false
        }
    }
}

public struct AudioDownloadRootView<Content>: View, SuperLog where Content: View {
    public nonisolated static var emoji: String { "⬇️" }
    private static var verbose: Bool { true }

    @EnvironmentObject private var man: MagicPlayMan
    @State private var downloadGeneration = 0
    @State private var activeDownloadAssets: [URL] = []
    private let scene: (any SceneProviding)?
    private var content: Content

    public init(
        scene: (any SceneProviding)?,
        @ViewBuilder content: () -> Content
    ) {
        self.scene = scene
        self.content = content()
    }

    public var body: some View {
        content
            .onAppear(perform: handleOnAppear)
            .onChange(of: scene?.currentScene) { _, newScene in
                handleCurrentSceneChanged(newScene)
            }
            .onPlayManAssetChanged(handlePlayManAssetChanged)
    }

    /// 检查是否应该激活下载功能
    private var shouldActivateDownload: Bool {
        scene?.currentScene == AppScene.music
    }
}

// MARK: - Event Handler

extension AudioDownloadRootView {
    /// 处理视图出现事件
    ///
    /// 当视图首次出现时触发，订阅播放器事件。
    func handleOnAppear() {
        guard shouldActivateDownload else {
            if Self.verbose {
                os_log("\(self.t)⏭️ 下载管理跳过：当前插件不是音频插件")
            }
            return
        }

        handleCurrentSceneChanged()
    }

    func handleCurrentSceneChanged(_ sceneValue: AppScene? = nil) {
        if let sceneValue, sceneValue != AppScene.music {
            downloadGeneration = AudioDownloadRequestPolicy.generationAfterDeactivation(downloadGeneration)
        }

        guard AudioDownloadRequestPolicy.shouldCheckCurrentAsset(
            isSceneActive: shouldActivateDownload,
            asset: man.currentAsset
        ) else { return }

        handlePlayManAssetChanged(man.currentAsset)
    }

    /// 处理播放资源变化事件
    ///
    /// 当播放器的音频资源改变时触发。
    /// 如果资源在 iCloud 且未下载，会自动触发下载。
    ///
    /// - Parameter url: 新的音频资源 URL，如果为 nil 则表示停止播放
    func handlePlayManAssetChanged(_ url: URL?) {
        guard AudioDownloadRequestPolicy.shouldStartDownload(
            isSceneActive: shouldActivateDownload,
            asset: url,
            isNotDownloaded: url?.isNotDownloaded == true,
            activeDownloads: activeDownloadAssets
        ), let url else { return }

        let generation = downloadGeneration
        activeDownloadAssets.append(url)
        Task { @MainActor in
            defer {
                activeDownloadAssets.removeAll { activeAsset in
                    AudioDownloadRequestPolicy.shouldApplyDownloadResult(
                        requestedAsset: activeAsset,
                        currentAsset: url,
                        isSceneActive: true
                    )
                }
            }

            guard AudioDownloadRequestPolicy.shouldApplyDownloadResult(
                requestedAsset: url,
                currentAsset: man.currentAsset,
                isSceneActive: shouldActivateDownload,
                currentGeneration: downloadGeneration,
                requestGeneration: generation
            ) else {
                return
            }

            do {
                try await url.ensureLocalAvailability()
                guard AudioDownloadRequestPolicy.shouldApplyDownloadResult(
                    requestedAsset: url,
                    currentAsset: man.currentAsset,
                    isSceneActive: shouldActivateDownload,
                    currentGeneration: downloadGeneration,
                    requestGeneration: generation
                ) else {
                    return
                }
                if Self.verbose {
                    os_log("\(self.t)✅ 音频文件下载完成: \(url.lastPathComponent)")
                }
            } catch {
                guard AudioDownloadRequestPolicy.shouldApplyDownloadResult(
                    requestedAsset: url,
                    currentAsset: man.currentAsset,
                    isSceneActive: shouldActivateDownload,
                    currentGeneration: downloadGeneration,
                    requestGeneration: generation
                ) else {
                    return
                }
                os_log(.error, "\(self.t)❌ 音频文件下载失败: \(error.localizedDescription)")
                alert_error(String(localized: "Download failed: \(error.localizedDescription)", bundle: .module))
            }
        }
    }
}
