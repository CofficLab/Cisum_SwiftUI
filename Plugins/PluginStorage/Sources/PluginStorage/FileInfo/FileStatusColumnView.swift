import MagicKit

import OSLog
import SwiftUI

struct FileStatusColumnView: View, SuperLog {
    nonisolated static let emoji: String = "🥩"

    let url: URL
    @State private var fileStatus: String = "检查中..."
    @State private var isChecking: Bool = true
    @State private var statusColor: Color = .gray

    @MainActor
    private static var statusCache: [String: (status: String, color: Color)] = [:]

    var body: some View {
        Text(fileStatus)
            .foregroundColor(statusColor)
            .task(id: url) {
                fileStatus = "检查中..."
                statusColor = .gray
                isChecking = true
                await checkFileStatus(verbose: false)
            }
    }

    private func checkFileStatus(verbose: Bool) async {
        let path = url.path(percentEncoded: false)

        // 检查缓存
        if let cached = await MainActor.run(body: { Self.statusCache[path] }) {
            updateState(fileStatus: cached.status, statusColor: cached.color, isChecking: false)
            if verbose {
                os_log("\(Self.t)📦 Using cached status for \(path)")
            }
            return
        }

        if verbose {
            os_log("\(Self.t)🔍 Checking file status for \(path)")
        }

        let result = await Task.detached(priority: .background) {
            Self.resolveStatus(for: url, verbose: verbose)
        }.value

        guard !Task.isCancelled else { return }

        Self.statusCache[path] = result
        updateState(fileStatus: result.status, statusColor: result.color, isChecking: false)
    }

    nonisolated private static func resolveStatus(for url: URL, verbose: Bool) -> (status: String, color: Color) {
        if verbose {
            os_log("\(Self.t)🔍 Checking file status for \(url.path(percentEncoded: false))")
        }

        if url.isFolder {
            return resolveDirectoryStatus(url)
        } else if url.checkIsICloud(verbose: false) {
            return resolveSingleFileStatus(url.isDownloaded)
        } else {
            return ("本地文件", Color.primary)
        }
    }

    nonisolated private static func resolveSingleFileStatus(_ isDownloaded: Bool) -> (status: String, color: Color) {
        if isDownloaded {
            ("已下载", Color.green)
        } else {
            ("未下载", Color.orange)
        }
    }

    nonisolated private static func resolveDirectoryStatus(_ directoryURL: URL) -> (status: String, color: Color) {
        // 使用 flatten() 获取所有文件
        let files = directoryURL.flatten()
        var fileStats = (downloaded: 0, notDownloaded: 0)

        for file in files where file.checkIsICloud(verbose: false) {
            if file.isDownloaded {
                fileStats.downloaded += 1
            } else {
                fileStats.notDownloaded += 1
            }
        }

        if fileStats.downloaded > 0 || fileStats.notDownloaded > 0 {
            return ("\(fileStats.downloaded)个已下载, \(fileStats.notDownloaded)个未下载",
                    fileStats.downloaded > 0 ? Color.green : Color.orange)
        } else {
            return ("本地目录", Color.primary)
        }
    }

    @MainActor
    private func updateState(fileStatus: String, statusColor: Color, isChecking: Bool) {
        self.fileStatus = fileStatus
        self.statusColor = statusColor
        self.isChecking = isChecking
    }
}

#Preview {
    FileStatusColumnView(url: URL(filePath: "/Users/user/Downloads/test.txt"))
}
