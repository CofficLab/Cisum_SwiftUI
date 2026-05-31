import MagicKit
import MagicAlert
import MagicPlayMan
import OSLog
import SwiftUI

public typealias AudioDownloadCurrentSceneProvider = @MainActor () -> String?

enum AudioDownloadRequestPolicy {
    static func shouldStartDownload(isSceneActive: Bool, asset: URL?, isNotDownloaded: Bool) -> Bool {
        isSceneActive && asset != nil && isNotDownloaded
    }

    static func shouldApplyDownloadResult(requestedAsset: URL, currentAsset: URL?, isSceneActive: Bool) -> Bool {
        isSceneActive && representsSameFile(requestedAsset, currentAsset)
    }

    private static func representsSameFile(_ lhs: URL?, _ rhs: URL?) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none):
            return true
        case let (.some(lhs), .some(rhs)):
            return lhs.resolvingSymlinksInPath().standardizedFileURL.path
                == rhs.resolvingSymlinksInPath().standardizedFileURL.path
        default:
            return false
        }
    }
}

public struct AudioDownloadRootView<Content>: View, SuperLog where Content: View {
    public nonisolated static var emoji: String { "⬇️" }
    private static var verbose: Bool { true }

    @EnvironmentObject private var man: MagicPlayMan
    private let currentSceneName: AudioDownloadCurrentSceneProvider
    private var content: Content

    public init(
        currentSceneName: @escaping AudioDownloadCurrentSceneProvider,
        @ViewBuilder content: () -> Content
    ) {
        self.currentSceneName = currentSceneName
        self.content = content()
    }

    public var body: some View {
        content
            .onAppear(perform: handleOnAppear)
            .onPlayManAssetChanged(handlePlayManAssetChanged)
    }

    /// 检查是否应该激活下载功能
    private var shouldActivateDownload: Bool {
        currentSceneName() == AudioDownloadPluginInfo.audioSceneName
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
            isNotDownloaded: url?.isNotDownloaded == true
        ), let url else { return }

        Task { @MainActor in
            guard AudioDownloadRequestPolicy.shouldApplyDownloadResult(
                requestedAsset: url,
                currentAsset: man.currentAsset,
                isSceneActive: shouldActivateDownload
            ) else {
                return
            }

            do {
                try await url.ensureLocalAvailability()
                guard AudioDownloadRequestPolicy.shouldApplyDownloadResult(
                    requestedAsset: url,
                    currentAsset: man.currentAsset,
                    isSceneActive: shouldActivateDownload
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
                    isSceneActive: shouldActivateDownload
                ) else {
                    return
                }
                os_log(.error, "\(self.t)❌ 音频文件下载失败: \(error.localizedDescription)")
                alert_error(String(localized: "Download failed: \(error.localizedDescription)", table: "Audio-Download", bundle: .module))
            }
        }
    }
}
