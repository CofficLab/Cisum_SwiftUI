import Foundation
import MagicAlert
import MagicKit
import MagicPlayMan
import OSLog
import PluginBook
import SwiftUI

public typealias BookProgressCurrentSceneProvider = @MainActor () -> String?
public typealias BookProgressURLProvider = @MainActor () -> URL?
public typealias BookProgressTimeProvider = @MainActor () -> TimeInterval?
public typealias BookProgressStoreCurrentURL = @MainActor (URL?) -> Void
public typealias BookProgressStoreCurrentTime = @MainActor (TimeInterval) -> Void
public typealias BookProgressSaveBookState = @Sendable (URL, URL, TimeInterval) async -> Void

public struct BookProgressRootView<Content>: View, SuperLog where Content: View {
    public nonisolated static var emoji: String { BookProgressPluginInfo.emoji }
    private let verbose = true

    @EnvironmentObject private var man: MagicPlayMan
    @State private var playbackSubscriptionID: UUID?

    private let content: Content
    private let targetSceneName: String
    private let currentSceneName: BookProgressCurrentSceneProvider
    private let currentBookURL: BookProgressURLProvider
    private let currentBookTime: BookProgressTimeProvider
    private let storeCurrentBookURL: BookProgressStoreCurrentURL
    private let storeCurrentBookTime: BookProgressStoreCurrentTime
    private let saveBookState: BookProgressSaveBookState

    public init(
        targetSceneName: String,
        currentSceneName: @escaping BookProgressCurrentSceneProvider,
        currentBookURL: @escaping BookProgressURLProvider,
        currentBookTime: @escaping BookProgressTimeProvider,
        storeCurrentBookURL: @escaping BookProgressStoreCurrentURL,
        storeCurrentBookTime: @escaping BookProgressStoreCurrentTime,
        saveBookState: @escaping BookProgressSaveBookState,
        @ViewBuilder content: () -> Content
    ) {
        self.targetSceneName = targetSceneName
        self.currentSceneName = currentSceneName
        self.currentBookURL = currentBookURL
        self.currentBookTime = currentBookTime
        self.storeCurrentBookURL = storeCurrentBookURL
        self.storeCurrentBookTime = storeCurrentBookTime
        self.saveBookState = saveBookState
        self.content = content()
    }

    public var body: some View {
        content
            .onAppear(perform: handleOnAppear)
            .onDisappear(perform: handleOnDisappear)
            .onPlayManStateChanged(handlePlayManStateChanged)
    }

    /// 检查是否应该激活书籍进度管理功能
    private var shouldActivateProgress: Bool {
        currentSceneName() == targetSceneName
    }
}

// MARK: - Action

private extension BookProgressRootView {
    /// 处理视图出现事件
    ///
    /// 当视图首次出现时触发，恢复上次播放的书籍和进度。
    func handleOnAppear() {
        guard shouldActivateProgress else {
            return
        }

        if verbose {
            os_log("\(self.t)👀 视图已出现，开始恢复书籍进度")
        }

        restoreBookProgress()

        // 订阅播放器事件，监听URL变化
        guard playbackSubscriptionID == nil else { return }

        playbackSubscriptionID = man.subscribe(
            name: "BookProgressPlugin",
            onCurrentURLChanged: { url in
                handleCurrentURLChanged(url)
            }
        )
    }

    /// 处理视图消失事件，释放播放器事件订阅。
    func handleOnDisappear() {
        guard let playbackSubscriptionID else { return }

        man.unsubscribe(playbackSubscriptionID)
        self.playbackSubscriptionID = nil
    }

    /// 恢复书籍播放进度
    ///
    /// 从持久化存储中恢复上次播放的书籍和时间进度。
    private func restoreBookProgress() {
        Task {
            if let url = currentBookURL() {
                guard isPlayableBookURL(url) else {
                    if self.verbose {
                        os_log("\(self.t)⚠️ 跳过已失效的书籍进度: \(url.shortPath())")
                    }
                    return
                }

                await man.play(url, autoPlay: false, reason: "restoreBookProgress")

                if let time = currentBookTime() {
                    man.seek(time: time, reason: self.className + ".restoreBookProgress")
                }

                if self.verbose {
                    os_log("\(self.t)✅ 恢复书籍进度: \(url.lastPathComponent)")
                }
            }
        }
    }

    private func isPlayableBookURL(_ url: URL) -> Bool {
        FileManager.default.fileExists(atPath: url.path)
            && !url.isFolder
            && BookPluginInfo.supportedExtensions.contains(url.pathExtension.lowercased())
    }

    /// 处理当前URL变化事件
    ///
    /// 当播放的URL改变时，保存书籍的播放进度。
    ///
    /// - Parameter url: 新的播放URL
    func handleCurrentURLChanged(_ url: URL) {
        guard shouldActivateProgress else { return }

        if self.verbose {
            os_log("\(self.t)📖 URL变化 -> \(url.shortPath())")
        }

        Task {
            // 保存全局状态（用于应用启动恢复）
            storeCurrentBookURL(url)

            // 保存每本书的状态（用于每本书独立进度）
            await saveBookState(currentURL: url)

            // 如果文件未下载，自动下载
            if url.isNotDownloaded {
                do {
                    try await url.download(reason: "BookProgressRootView")
                    if self.verbose {
                        os_log("\(self.t)✅ 书籍文件下载完成")
                    }
                } catch let error {
                    os_log(.error, "\(self.t)❌ 书籍文件下载失败: \(error.localizedDescription)")
                    alert_error(String(localized: "Download failed: \(error.localizedDescription)", table: "Book-Progress", bundle: .module))
                }
            }
        }
    }

    /// 处理播放器状态变化事件。
    ///
    /// 暂停时保存全局播放时间和当前书籍的独立进度，保证下次进入书籍场景能恢复到准确位置。
    func handlePlayManStateChanged(_ isPlaying: Bool) {
        guard shouldActivateProgress else { return }
        guard man.state == .paused, let currentURL = man.currentAsset else { return }

        storeCurrentBookTime(man.currentTime)

        Task {
            await saveBookState(currentURL: currentURL)
        }

        if self.verbose {
            os_log("\(self.t)💾 保存书籍播放时间: \(man.currentTime)s")
        }
    }

    /// 保存书籍状态
    ///
    /// 保存当前书籍的播放进度到 BookState 模型。
    ///
    /// - Parameter currentURL: 当前播放的URL
    private func saveBookState(currentURL: URL) async {
        // 找到当前URL所属的书籍
        guard let bookURL = await findBookForURL(currentURL) else {
            if self.verbose {
                os_log("\(self.t)⚠️ 无法找到 \(currentURL.lastPathComponent) 所属的书籍")
            }
            return
        }

        // 获取当前播放时间
        let currentTime = man.currentTime

        // 更新书籍状态（保存当前章节和时间）
        if self.verbose {
            os_log("\(self.t)💾 保存书籍状态: \(bookURL.lastPathComponent) -> \(currentURL.lastPathComponent) @ \(currentTime)s")
        }

        await saveBookState(bookURL, currentURL, currentTime)
    }

    /// 查找URL所属的书籍
    ///
    /// - Parameter url: 要查找的URL
    /// - Returns: 所属书籍的URL，如果未找到则返回nil
    private func findBookForURL(_ url: URL) async -> URL? {
        let parentURL = bookRoot(containing: url)

        var isDirectory: ObjCBool = false
        if FileManager.default.fileExists(atPath: parentURL.path, isDirectory: &isDirectory),
           isDirectory.boolValue {
            return parentURL
        } else if self.verbose {
            do {
                _ = try FileManager.default.contentsOfDirectory(at: parentURL, includingPropertiesForKeys: nil)
            } catch {
                os_log("\(self.t)⚠️ 无法读取目录内容: \(error.localizedDescription)")
            }
        }

        if self.verbose {
            os_log("\(self.t)⚠️ 父路径不是书籍目录: \(parentURL.shortPath())")
        }

        return nil
    }

    private func bookRoot(containing url: URL) -> URL {
        guard let bookDisk = BookPlugin.getBookDisk() else {
            return url.deletingLastPathComponent()
        }

        let diskPath = bookDisk.standardizedFileURL.path
        var candidate = url.deletingLastPathComponent().standardizedFileURL

        while candidate.deletingLastPathComponent().standardizedFileURL.path != diskPath,
              candidate.path.hasPrefix(diskPath) {
            candidate = candidate.deletingLastPathComponent().standardizedFileURL
        }

        return candidate
    }
}
