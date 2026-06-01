import CisumUI
import Foundation
import MagicKit
import MagicAlert
import MagicPlayMan
import OSLog
import SwiftUI

enum AudioItemFileSizeLoadPolicy {
    static func shouldApplySize(currentURL: URL, requestedURL: URL) -> Bool {
        representsSameFile(currentURL, requestedURL)
    }

    private static func representsSameFile(_ lhs: URL, _ rhs: URL) -> Bool {
        lhs.isSameFileLocation(as: rhs)
    }
}

enum AudioItemFileSizeReadPolicy {
    static func fileSize(from attributes: [FileAttributeKey: Any]) -> Int64? {
        if let number = attributes[.size] as? NSNumber {
            return normalizedSize(number)
        }

        if let size = attributes[.size] as? Int {
            return normalizedSize(Int64(size))
        }

        if let size = attributes[.size] as? Int64 {
            return normalizedSize(size)
        }

        if let size = attributes[.size] as? UInt64 {
            guard size <= UInt64(Int64.max) else { return Int64.max }
            return Int64(size)
        }

        return nil
    }

    private static func normalizedSize(_ size: Int64) -> Int64 {
        max(size, 0)
    }

    private static func normalizedSize(_ number: NSNumber) -> Int64 {
        if number.compare(NSNumber(value: 0)) == .orderedAscending {
            return 0
        }

        if number.compare(NSNumber(value: Int64.max)) == .orderedDescending {
            return Int64.max
        }

        return number.int64Value
    }
}

enum AudioItemFileSizeDisplayState: Equatable {
    case loading
    case unavailable
    case size(Int64)
}

enum AudioItemFileSizeDisplayPolicy {
    static func state(fileSize: Int64?, isUnavailable: Bool) -> AudioItemFileSizeDisplayState {
        if let fileSize {
            return .size(fileSize)
        }

        return isUnavailable ? .unavailable : .loading
    }
}

@MainActor
enum AudioItemFileSizeCache {
    private struct Entry {
        let size: Int64?
    }

    private static var entries: [String: Entry] = [:]

    static func cachedSize(for url: URL) -> Int64?? {
        let key = cacheKey(for: url)
        guard let entry = entries[key] else {
            return nil
        }
        return .some(entry.size)
    }

    static func store(_ size: Int64?, for url: URL) {
        let key = cacheKey(for: url)
        entries[key] = Entry(size: size)
    }

    static func remove(_ urls: [URL]) {
        let keys = urls.map(cacheKey(for:))
        for key in keys {
            entries.removeValue(forKey: key)
        }
    }

    static func removeAll() {
        entries.removeAll()
    }

    private static func cacheKey(for url: URL) -> String {
        AudioListFileIdentity.canonicalIdentity(for: url)
    }
}

enum AudioItemFileActionPolicy {
    static func canRevealInFinder(_ url: URL) -> Bool {
        pathExistsIncludingSymlink(url)
    }

    static func pathExistsIncludingSymlink(_ url: URL) -> Bool {
        if FileManager.default.fileExists(atPath: url.path) {
            return true
        }

        return (try? url.resourceValues(forKeys: [.isSymbolicLinkKey]).isSymbolicLink) == true
    }
}

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
    @State private var fileSizeUnavailable = false
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
                        switch AudioItemFileSizeDisplayPolicy.state(
                            fileSize: fileSize,
                            isUnavailable: fileSizeUnavailable
                        ) {
                        case .size(let fileSize):
                            AppSizeLabel(bytes: fileSize)
                        case .unavailable:
                            Text("Unavailable", tableName: "Audio-DBView", bundle: .module)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        case .loading:
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
                Button(action: playAudio) {
                    Label {
                        Text("Play", tableName: "Audio-DBView", bundle: .module)
                    } icon: {
                        Image(systemName: "play.fill")
                    }
                }

                if AudioItemFileActionPolicy.canRevealInFinder(url) {
                    Button {
                        showInFinder()
                    } label: {
                        Label {
                            Text("Show in Finder", tableName: "Audio-DBView", bundle: .module)
                        } icon: {
                            Image(systemName: "finder")
                        }
                    }
                }

                Button {
                    exportToDownloads()
                } label: {
                    Label {
                        Text("Export to Downloads", tableName: "Audio-DBView", bundle: .module)
                    } icon: {
                        Image(systemName: "arrow.down.doc")
                    }
                }

                Divider()

                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    Label {
                        Text("Delete", tableName: "Audio-DBView", bundle: .module)
                    } icon: {
                        Image(systemName: "trash")
                    }
                }
            }
        #endif
            .confirmationDialog(
                Text("Delete this file?", tableName: "Audio-DBView", bundle: .module),
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button(role: .cancel) {} label: {
                    Text("Cancel", tableName: "Audio-DBView", bundle: .module)
                }
                Button(role: .destructive) {
                    deleteFile()
                } label: {
                    Text("Delete", tableName: "Audio-DBView", bundle: .module)
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
        fileSizeUnavailable = false

        let requestedURL = url
        if let cachedSize = AudioItemFileSizeCache.cachedSize(for: requestedURL) {
            fileSize = cachedSize
            fileSizeUnavailable = cachedSize == nil
            return
        }

        let size = await Task.detached(priority: .background) { () -> Int64? in
            guard let attributes = try? FileManager.default.attributesOfItem(atPath: requestedURL.path) else {
                return nil
            }

            return AudioItemFileSizeReadPolicy.fileSize(from: attributes)
        }.value

        guard !Task.isCancelled,
              AudioItemFileSizeLoadPolicy.shouldApplySize(currentURL: url, requestedURL: requestedURL) else {
            return
        }

        AudioItemFileSizeCache.store(size, for: requestedURL)
        fileSize = size
        fileSizeUnavailable = size == nil
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

    nonisolated static func copyToDownloads(_ sourceURL: URL, downloadsURL: URL? = nil) async throws -> URL {
        // 获取下载目录
        let downloadsURL = try downloadsURL ?? FileManager.default.url(
            for: .downloadsDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )

        let finalDestinationURL = uniqueDestination(for: sourceURL, in: downloadsURL)
        let sourceToCopy = copySourceURL(for: sourceURL)

        try await sourceToCopy.ensureLocalAvailability()

        try FileManager.default.copyItem(at: sourceToCopy, to: finalDestinationURL)
        return finalDestinationURL
    }

    nonisolated private static func copySourceURL(for sourceURL: URL) -> URL {
        let resolvedURL = sourceURL.resolvingSymlinksInPath().standardizedFileURL
        guard FileManager.default.fileExists(atPath: resolvedURL.path) else {
            return sourceURL
        }

        return resolvedURL
    }

    nonisolated static func uniqueDestination(for sourceURL: URL, in directory: URL) -> URL {
        var destinationURL = directory.appendingPathComponent(sourceURL.lastPathComponent)
        var counter = 2

        while AudioItemFileActionPolicy.pathExistsIncludingSymlink(destinationURL) {
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

                if AudioDeletePlaybackPolicy.shouldResetDirectlyAfterDelete(
                    currentURL: playMan.currentURL,
                    deletedURLs: [url],
                    isPlaybackControllerHandlingDeletion: true
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
