import Foundation
import MagicAlert
import MagicKit
import MagicPlayMan
import OSLog
import SwiftUI

public typealias BookProgressCurrentSceneProvider = @MainActor () -> String?
public typealias BookProgressURLProvider = @MainActor () -> URL?
public typealias BookProgressTimeProvider = @MainActor () -> TimeInterval?
public typealias BookProgressStoreCurrentURL = @MainActor (URL?) -> Void
public typealias BookProgressSaveBookState = @Sendable (URL, URL, TimeInterval) async -> Void

public struct BookProgressRootView<Content>: View, SuperLog where Content: View {
    public nonisolated static var emoji: String { BookProgressPluginInfo.emoji }
    private let verbose = true

    @EnvironmentObject private var man: MagicPlayMan

    private let content: Content
    private let targetSceneName: String
    private let currentSceneName: BookProgressCurrentSceneProvider
    private let currentBookURL: BookProgressURLProvider
    private let currentBookTime: BookProgressTimeProvider
    private let storeCurrentBookURL: BookProgressStoreCurrentURL
    private let saveBookState: BookProgressSaveBookState

    public init(
        targetSceneName: String,
        currentSceneName: @escaping BookProgressCurrentSceneProvider,
        currentBookURL: @escaping BookProgressURLProvider,
        currentBookTime: @escaping BookProgressTimeProvider,
        storeCurrentBookURL: @escaping BookProgressStoreCurrentURL,
        saveBookState: @escaping BookProgressSaveBookState,
        @ViewBuilder content: () -> Content
    ) {
        self.targetSceneName = targetSceneName
        self.currentSceneName = currentSceneName
        self.currentBookURL = currentBookURL
        self.currentBookTime = currentBookTime
        self.storeCurrentBookURL = storeCurrentBookURL
        self.saveBookState = saveBookState
        self.content = content()
    }

    public var body: some View {
        content
            .onAppear(perform: handleOnAppear)
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
        man.subscribe(
            name: "BookProgressPlugin",
            onCurrentURLChanged: { url in
                handleCurrentURLChanged(url)
            }
        )
    }

    /// 恢复书籍播放进度
    ///
    /// 从持久化存储中恢复上次播放的书籍和时间进度。
    private func restoreBookProgress() {
        Task {
            if let url = currentBookURL() {
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
        // 这里需要访问 BookRepo 来查找书籍
        // 由于插件解耦，我们需要一个简化版本

        // 假设书籍文件夹结构：书籍URL是包含当前文件的父目录
        // 这是一个简化的实现，实际可能需要更复杂的逻辑
        let parentURL = url.deletingLastPathComponent()

        // 检查父目录是否是书籍目录（通过检查是否有多个文件）
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: parentURL, includingPropertiesForKeys: nil)
            if contents.count > 1 { // 如果有多个文件，认为是书籍目录
                return parentURL
            }
        } catch {
            if self.verbose {
                os_log("\(self.t)⚠️ 无法读取目录内容: \(error.localizedDescription)")
            }
        }

        return nil
    }
}
