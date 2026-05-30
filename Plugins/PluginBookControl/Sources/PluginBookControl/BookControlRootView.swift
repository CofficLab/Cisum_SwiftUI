import Foundation
import MagicKit
import MagicPlayMan
import OSLog
import PluginBook
import SwiftUI

public typealias BookControlCurrentSceneProvider = @MainActor () -> String?

public struct BookControlRootView<Content>: View, SuperLog where Content: View {
    public nonisolated static var emoji: String { BookControlPluginInfo.emoji }
    private let verbose = false

    @EnvironmentObject private var man: MagicPlayMan
    @State private var playbackSubscriptionID: UUID?

    private let content: Content
    private let targetSceneName: String
    private let currentSceneName: BookControlCurrentSceneProvider

    public init(
        targetSceneName: String,
        currentSceneName: @escaping BookControlCurrentSceneProvider,
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
            .onReceive(NotificationCenter.default.publisher(for: .bookDBDeleted), perform: handleBookDBDeleted)
            .onReceive(NotificationCenter.default.publisher(for: .bookControlStorageLocationDidReset)) { _ in
                handleStorageLocationDidReset()
            }
    }

    /// 检查是否应该激活书籍播放控制功能
    private var shouldActivateControl: Bool {
        currentSceneName() == targetSceneName
    }
}

// MARK: - Action

private extension BookControlRootView {
    /// 处理视图出现事件
    ///
    /// 当视图首次出现时触发，执行初始化操作。
    func handleOnAppear() {
        updateControlActivation(for: currentSceneName())
    }

    func handleCurrentSceneChanged(_ sceneName: String?) {
        updateControlActivation(for: sceneName)
    }

    private func updateControlActivation(for sceneName: String?) {
        if sceneName == targetSceneName {
            activateControl()
        } else {
            deactivateControl()
        }
    }

    private func activateControl() {
        guard shouldActivateControl else {
            if verbose {
                os_log("\(self.t)⏭️ 书籍播放控制跳过：当前场景不是书籍场景")
            }
            return
        }

        if verbose {
            os_log("\(self.t)👀 视图已出现，开始初始化书籍播放控制")
        }

        // 订阅播放器事件
        guard playbackSubscriptionID == nil else { return }

        playbackSubscriptionID = man.subscribe(
            name: "BookControlPlugin",
            onPreviousRequested: { asset in
                handlePreviousRequested(asset)
            },
            onNextRequested: { asset in
                handleNextRequested(asset)
            }
        )
    }

    func handleOnDisappear() {
        deactivateControl()
    }

    private func deactivateControl() {
        guard let playbackSubscriptionID else { return }

        man.unsubscribe(playbackSubscriptionID)
        self.playbackSubscriptionID = nil
    }

    func bookRoot(containing asset: URL) -> URL {
        guard let bookDisk = BookPlugin.getBookDisk() else {
            return asset.deletingLastPathComponent()
        }

        let diskPath = bookDisk.standardizedFileURL.path
        var candidate = asset.deletingLastPathComponent().standardizedFileURL

        while candidate.deletingLastPathComponent().standardizedFileURL.path != diskPath,
              candidate.path.hasPrefix(diskPath) {
            candidate = candidate.deletingLastPathComponent().standardizedFileURL
        }

        return candidate
    }

    func relativePath(_ url: URL, in root: URL) -> String {
        let rootPath = root.standardizedFileURL.path
        let path = url.standardizedFileURL.path

        guard path.hasPrefix(rootPath) else {
            return url.lastPathComponent
        }

        return String(path.dropFirst(rootPath.count)).trimmingCharacters(in: CharacterSet(charactersIn: "/"))
    }

    func playableChapters(of asset: URL) -> [URL] {
        let root = bookRoot(containing: asset)

        return root
            .flatten()
            .filter { url in
                !url.isFolder
                    && FileManager.default.fileExists(atPath: url.path)
                    && BookPluginInfo.supportedExtensions.contains(url.pathExtension.lowercased())
            }
            .sorted {
                relativePath($0, in: root).localizedStandardCompare(relativePath($1, in: root)) == .orderedAscending
            }
    }

    func adjacentAsset(to asset: URL, offset: Int) -> URL? {
        let chapters = playableChapters(of: asset)
        return Self.adjacentAsset(
            in: chapters,
            current: asset,
            offset: offset,
            playMode: man.playMode
        )
    }

    func contains(_ parent: URL, asset: URL) -> Bool {
        let parentPath = parent.standardizedFileURL.path
        let assetPath = asset.standardizedFileURL.path
        return assetPath == parentPath || assetPath.hasPrefix(parentPath + "/")
    }

    func handleBookDBDeleted(_ notification: Notification) {
        guard let deletedURLs = notification.userInfo?["urls"] as? [URL],
              let currentAsset = man.asset,
              deletedURLs.contains(where: { contains($0, asset: currentAsset) }) else {
            return
        }

        Task {
            await man.reset(reason: "BookControlRootView.deletedCurrentAsset")
        }
    }

    func handleStorageLocationDidReset() {
        Task {
            await man.reset(reason: "BookControlRootView.storageLocationDidReset")
        }
    }

    /// 处理上一章请求
    /// - Parameter asset: 当前播放的书籍章节资源
    func handlePreviousRequested(_ asset: URL) {
        guard shouldActivateControl else { return }

        if verbose {
            os_log("\(self.t)⏮️ 请求上一章")
        }

        if let prev = adjacentAsset(to: asset, offset: -1) {
            Task {
                await man.play(prev, reason: "handlePreviousRequested")
                if verbose {
                    os_log("\(self.t)✅ 播放上一章: \(prev.lastPathComponent)")
                }
            }
        } else {
            if verbose {
                os_log("\(self.t)⚠️ 没有上一章")
            }
        }
    }

    /// 处理下一章请求
    /// - Parameter asset: 当前播放的书籍章节资源
    func handleNextRequested(_ asset: URL) {
        guard shouldActivateControl else { return }

        if verbose {
            os_log("\(self.t)⏭️ 请求下一章")
        }

        if let next = adjacentAsset(to: asset, offset: 1) {
            Task {
                await man.play(next, reason: "handleNextRequested")
                if verbose {
                    os_log("\(self.t)✅ 播放下一章: \(next.lastPathComponent)")
                }
            }
        } else {
            if verbose {
                os_log("\(self.t)⚠️ 没有下一章")
            }
        }
    }
}

private extension Notification.Name {
    static let bookControlStorageLocationDidReset = Notification.Name("storageLocationDidReset")
}

extension BookControlRootView {
    nonisolated static func adjacentAsset(
        in chapters: [URL],
        current asset: URL,
        offset: Int,
        playMode: MagicPlayMode
    ) -> URL? {
        guard !chapters.isEmpty, let index = chapters.firstIndex(of: asset) else { return nil }

        let adjacentIndex = index + offset
        if chapters.indices.contains(adjacentIndex) {
            return chapters[adjacentIndex]
        }

        switch playMode {
        case .repeatAll:
            return offset > 0 ? chapters.first : chapters.last
        case .shuffle:
            return chapters.filter { $0 != asset }.randomElement() ?? chapters.first
        case .sequence, .loop:
            return nil
        }
    }
}
