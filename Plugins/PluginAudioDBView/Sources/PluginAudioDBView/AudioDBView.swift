import CisumUI
import Foundation
import MagicAlert
import MagicKit
import OSLog
import SwiftData
import SwiftUI
import UniformTypeIdentifiers
import PluginAudio

@MainActor
public struct AudioDBView: View, SuperLog, SuperThread, SuperEvent {
    public nonisolated static let emoji = "🐘"
    public nonisolated static let verbose = false

    @Environment(\.audioDBDependencies) private var dependencies
    @LumiTheme private var appTheme
    private let isDemoMode: Bool

    /// 是否正在排序
    @State private var isSorting: Bool = false

    /// 当前排序模式
    @State private var sortMode: SortMode = .none

    public init(isDemoMode: Bool) {
        self.isDemoMode = isDemoMode
    }

    public var body: some View {
        if Self.verbose {
            os_log("\(self.t)📺 开始渲染")
        }

        return Group {
            if isDemoMode {
                EmptyView()
            } else {
                AudioList()
            }
        }
        .overlay(alignment: .center) {
            if isSorting {
                AudioDBTips(variant: .sorting)
                    .transition(.opacity)
            }
        }
        .frame(maxHeight: .infinity)
        .background(appTheme.background.ignoresSafeArea())
        .fileImporter(
            isPresented: dependencies.isImporting,
            allowedContentTypes: [.audio],
            allowsMultipleSelection: true,
            onCompletion: handleFileImport
        )
        .onDBSorting(perform: handleSorting)
        .onDBSortDone(perform: handleSortDone)
    }

    /// 排序模式枚举
    ///
    /// 定义音频列表的排序方式和对应的 UI 显示。
    enum SortMode: String {
        /// 随机排序
        case random
        /// 顺序排序
        case order
        /// 未指定排序方式
        case none

        /// 排序模式对应的图标
        var icon: String {
            switch self {
            case .random: return "shuffle"
            case .order: return "arrow.up.arrow.down"
            case .none: return "arrow.triangle.2.circlepath"
            }
        }

        /// 排序模式对应的描述文本
        var description: String {
            switch self {
            case .random: return "正在随机排序..."
            case .order: return "正在顺序排序..."
            case .none: return "正在排序..."
            }
        }
    }
}

// MARK: - Action

extension AudioDBView {
    /// 获取存储根目录
    ///
    /// 异步获取音频文件的存储根目录路径。
    ///
    /// - Returns: 存储根目录的 URL
    private func fetchStorageRoot() async -> URL? {
        dependencies.audioDisk()
    }

    /// 复制文件到存储目录
    ///
    /// 将选中的音频文件复制到应用的存储目录中。
    ///
    /// - Parameters:
    ///   - urls: 要复制的文件 URL 列表
    ///   - storageRoot: 目标存储根目录
    private func copyFiles(_ urls: [URL], to storageRoot: URL) async throws -> [URL] {
        if Self.verbose {
            os_log("\(self.t)📋 准备复制 \(urls.count) 个文件")
        }

        // 发送复制文件事件
        self.emit(name: .CopyFiles, object: self, userInfo: [
            "urls": urls,
            "folder": storageRoot,
        ])

        return try await Task.detached(priority: .userInitiated) {
            try Self.copyFilesInBackground(urls, to: storageRoot)
        }.value
    }

    nonisolated private static func copyFilesInBackground(_ urls: [URL], to storageRoot: URL) throws -> [URL] {
        try FileManager.default.createDirectory(at: storageRoot, withIntermediateDirectories: true)

        var copiedURLs: [URL] = []

        // 逐个复制文件
        for url in urls {
            let destination = Self.uniqueDestination(for: url, in: storageRoot)

            if Self.verbose {
                os_log("\(Self.t)📄 复制: \(url.lastPathComponent)")
            }

            try copySecurityScopedFile(url, to: destination)
            copiedURLs.append(destination)
        }

        if Self.verbose {
            os_log("\(Self.t)✅ 全部文件复制完成")
        }

        return copiedURLs
    }

    nonisolated private static func uniqueDestination(for source: URL, in directory: URL) -> URL {
        let baseName = source.deletingPathExtension().lastPathComponent
        let fileExtension = source.pathExtension
        let normalizedBaseName = baseName.isEmpty ? "Imported Audio" : baseName

        var candidate = destination(
            named: normalizedBaseName,
            pathExtension: fileExtension,
            in: directory
        )
        var suffix = 2

        while FileManager.default.fileExists(atPath: candidate.path) {
            candidate = destination(
                named: "\(normalizedBaseName) \(suffix)",
                pathExtension: fileExtension,
                in: directory
            )
            suffix += 1
        }

        return candidate
    }

    nonisolated private static func copySecurityScopedFile(_ source: URL, to destination: URL) throws {
        let hasAccess = source.startAccessingSecurityScopedResource()
        guard hasAccess else {
            throw NSError(
                domain: "AudioDBView",
                code: 1,
                userInfo: [
                    NSLocalizedDescriptionKey: String(localized: "Permission to access the original file was denied", table: "Audio-DBView", bundle: .module)
                ]
            )
        }

        defer {
            source.stopAccessingSecurityScopedResource()
        }

        if source.checkIsICloud(verbose: false), source.isNotDownloaded {
            try FileManager.default.startDownloadingUbiquitousItem(at: source)
        }

        try FileManager.default.copyItem(at: source, to: destination)
    }

    nonisolated private static func destination(named name: String, pathExtension: String, in directory: URL) -> URL {
        let destination = directory.appendingPathComponent(name)
        guard !pathExtension.isEmpty else {
            return destination
        }

        return destination.appendingPathExtension(pathExtension)
    }
}

// MARK: - Event Handler

extension AudioDBView {
    /// 处理文件导入
    ///
    /// 当用户通过文件选择器导入音频文件时触发。
    /// 获取存储根目录并将文件复制到该目录。
    ///
    /// - Parameter result: 文件导入的结果，包含选中的文件 URL 或错误信息
    private func handleFileImport(result: Result<[URL], Error>) {
        Task {
            switch result {
            case let .success(urls):
                if Self.verbose {
                    os_log("\(self.t)📥 处理文件导入，文件数量: \(urls.count)")
                }

                guard !urls.isEmpty else {
                    alert_error(String(localized: "No files were added", table: "Audio-DBView", bundle: .module))
                    return
                }

                guard let storageRoot = await fetchStorageRoot() else {
                    alert_error(String(localized: "Storage location is unavailable", table: "Audio-DBView", bundle: .module))
                    return
                }

                do {
                    let copiedURLs = try await copyFiles(urls, to: storageRoot)
                    if let repo = dependencies.audioRepo() {
                        await repo.sync(copiedURLs, isFirst: false)
                    }
                } catch {
                    os_log(.error, "\(self.t)❌ 复制文件失败: \(error.localizedDescription)")
                    alert_error(String(localized: "Import failed: \(error.localizedDescription)", table: "Audio-DBView", bundle: .module))
                }

            case let .failure(error):
                os_log(.error, "\(self.t)❌ 导入文件失败: \(error.localizedDescription)")
                alert_error(String(localized: "Import failed: \(error.localizedDescription)", table: "Audio-DBView", bundle: .module))
            }
        }
    }

    /// 处理排序开始事件
    ///
    /// 当数据库开始排序时触发，显示排序动画和提示。
    ///
    /// - Parameter notification: 包含排序模式信息的通知
    func handleSorting(_ notification: Notification) {
        if Self.verbose {
            os_log("\(self.t)🔄 开始排序")
        }

        withAnimation {
            isSorting = true
        }

        if let mode = notification.userInfo?["mode"] as? String {
            sortMode = SortMode(rawValue: mode) ?? .none

            if Self.verbose {
                os_log("\(self.t)📋 排序模式: \(mode)")
            }
        }
    }

    /// 处理排序完成事件
    ///
    /// 当数据库排序完成时触发，隐藏排序动画。
    ///
    /// - Parameter notification: 排序完成的通知
    func handleSortDone(_ notification: Notification) {
        if Self.verbose {
            os_log("\(self.t)✅ 排序完成")
        }

        withAnimation {
            isSorting = false
        }
    }
}
