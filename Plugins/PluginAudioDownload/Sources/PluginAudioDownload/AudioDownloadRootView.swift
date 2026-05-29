import MagicKit
import MagicPlayMan
import OSLog
import SwiftUI

public typealias AudioDownloadCurrentSceneProvider = @MainActor () -> String?

public struct AudioDownloadRootView<Content>: View, SuperLog where Content: View {
    public nonisolated static var emoji: String { "⬇️" }
    private static var verbose: Bool { true }

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
        guard shouldActivateDownload else { return }
    }
}
