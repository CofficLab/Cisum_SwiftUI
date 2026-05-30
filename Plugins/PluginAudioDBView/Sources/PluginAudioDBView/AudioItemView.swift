import CisumUI
import Foundation
import MagicKit
import MagicAlert
import MagicPlayMan
import OSLog
import SwiftUI

/// 音频列表项视图组件
/// 用于在 AudioList 中展示单个音频文件
struct AudioItemView: View, Equatable, SuperLog {
    nonisolated static let emoji = "🎵"
    nonisolated static let verbose = false

    @EnvironmentObject var playMan: MagicPlayMan
    @Environment(\.audioDBDependencies) private var dependencies

    let url: URL

    /// 文件大小
    @State private var fileSize: Int64?
    /// 删除确认对话框
    @State private var showDeleteConfirmation = false

    nonisolated static func == (lhs: AudioItemView, rhs: AudioItemView) -> Bool {
        lhs.url == rhs.url
    }

    init(_ url: URL) {
        self.url = url
    }
}

// MARK: - View

extension AudioItemView {
    var body: some View {
        AppListRow {
            HStack(alignment: .center, spacing: 12) {
                // 头像部分
                url.makeAvatarView(verbose: Self.verbose)
                    .magicSize(.init(width: 40, height: 40))
                    .magicAvatarShape(.circle)
                    .magicBackground(.blue.opacity(0.1))
                    .magicDownloadMonitor(true)

                // 文件信息部分
                VStack(alignment: .leading, spacing: 4) {
                    Text(url.lastPathComponent)
                        .font(.headline)
                        .lineLimit(1)

                    HStack {
                        if let fileSize {
                            AppSizeLabel(bytes: fileSize)
                        } else {
                            Text("...")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Spacer()
            }
        }
        .tag(url as URL?)
        .task(id: url) {
            await loadFileSize()
        }
        #if os(macOS)
            .contextMenu {
                AppContextMenuRow("播放", systemImage: "play.fill", action: playAudio)

                AppContextMenuRow("在 Finder 中显示", systemImage: "finder") {
                    showInFinder()
                }

                AppContextMenuRow("导出到下载目录", systemImage: "arrow.down.doc") {
                    exportToDownloads()
                }

                Divider()

                AppContextMenuRow("删除", systemImage: "trash", role: .destructive) {
                    showDeleteConfirmation = true
                }
            }
        #endif
            .confirmationDialog(
                Text("确定要删除这个文件吗？", tableName: "Audio-DBView", bundle: .module),
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button(role: .cancel) {} label: {
                    Text("取消", tableName: "Audio-DBView", bundle: .module)
                }
                Button(role: .destructive) {
                    deleteFile()
                } label: {
                    Text("删除", tableName: "Audio-DBView", bundle: .module)
                }
            } message: {
                Text(url.lastPathComponent)
            }
    }
}

// MARK: - Action

extension AudioItemView {
    /// 在后台加载文件大小
    private func loadFileSize() async {
        fileSize = nil

        let size = await Task.detached(priority: .background) {
            let size = (try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? NSNumber)?.int64Value
            return size
        }.value

        guard !Task.isCancelled else { return }
        fileSize = size
    }

    /// 导出到下载目录
    private func exportToDownloads() {
        let sourceURL = url
        Task {
            do {
                let finalDestinationURL = try await Task.detached(priority: .userInitiated) {
                    try await Self.copyToDownloads(sourceURL)
                }.value

                if Self.verbose {
                    os_log("\(Self.t)✅ 文件已导出到: \(finalDestinationURL.path)")
                }
                alert_info(String(localized: "File copied to Downloads", table: "Audio-DBView", bundle: .module))
            } catch {
                if Self.verbose {
                    os_log("\(Self.t)❌ 导出文件失败: \(error.localizedDescription)")
                }
                alert_error(String(localized: "Export failed: \(error.localizedDescription)", table: "Audio-DBView", bundle: .module))
            }
        }
    }

    nonisolated private static func copyToDownloads(_ sourceURL: URL) async throws -> URL {
        // 获取下载目录
        let downloadsURL = try FileManager.default.url(
            for: .downloadsDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )

        let finalDestinationURL = uniqueDestination(for: sourceURL, in: downloadsURL)

        try await sourceURL.ensureLocalAvailability()

        try FileManager.default.copyItem(at: sourceURL, to: finalDestinationURL)
        return finalDestinationURL
    }

    nonisolated private static func uniqueDestination(for sourceURL: URL, in directory: URL) -> URL {
        var destinationURL = directory.appendingPathComponent(sourceURL.lastPathComponent)
        var counter = 1

        while FileManager.default.fileExists(atPath: destinationURL.path) {
            let fileNameWithoutExtension = sourceURL.deletingPathExtension().lastPathComponent
            let fileExtension = sourceURL.pathExtension
            let newFileName = fileExtension.isEmpty
                ? "\(fileNameWithoutExtension) \(counter)"
                : "\(fileNameWithoutExtension) \(counter).\(fileExtension)"
            destinationURL = directory.appendingPathComponent(newFileName)
            counter += 1
        }

        return destinationURL
    }

    /// 播放音频
    private func playAudio() {
        Task {
            await playMan.play(url, reason: "音频列表右键菜单")
            if Self.verbose {
                os_log("\(Self.t)▶️ 播放音频: \(url.lastPathComponent)")
            }
        }
    }

    /// 在 Finder 中显示
    private func showInFinder() {
        #if os(macOS)
            NSWorkspace.shared.activateFileViewerSelecting([url])
            if Self.verbose {
                os_log("\(Self.t)🔍 在 Finder 中显示: \(url.path)")
            }
        #endif
    }

    /// 删除文件
    private func deleteFile() {
        Task {
            do {
                guard let repo = dependencies.audioRepo() else {
                    alert_error(String(localized: "Delete failed: audio repository is unavailable", table: "Audio-DBView", bundle: .module))
                    return
                }

                try await repo.deleteAudios([url])

                if AudioDeletePlaybackPolicy.shouldResetAfterDelete(
                    currentURL: playMan.currentURL,
                    deletedURLs: [url]
                ) {
                    await playMan.reset(reason: "删除文件")
                    if Self.verbose {
                        os_log("\(Self.t)⏹️ 停止播放当前文件")
                    }
                }

                if Self.verbose {
                    os_log("\(Self.t)🗑️ 文件已删除: \(url.path)")
                }
                alert_info(String(localized: "File deleted", table: "Audio-DBView", bundle: .module))
            } catch {
                if Self.verbose {
                    os_log("\(Self.t)❌ 删除文件失败: \(error.localizedDescription)")
                }
                alert_error(String(localized: "Delete failed: \(error.localizedDescription)", table: "Audio-DBView", bundle: .module))
            }
        }
    }
}
